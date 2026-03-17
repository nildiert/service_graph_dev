# frozen_string_literal: true

module ServiceGraphDev
  # Analyzes dependencies between service classes via static analysis.
  # Scans all files matched by ServiceGraphDev.configuration.service_globs
  # in two passes: first collect class names, then detect cross-references.
  class Analyzer
    CACHE_KEY = "service_graph_dev/v2"

    def self.analyze_cached
      ttl = ServiceGraphDev.configuration.cache_ttl
      Rails.cache.fetch(CACHE_KEY, expires_in: ttl) { new.analyze }
    end

    def self.invalidate_cache
      Rails.cache.delete(CACHE_KEY)
    end

    def analyze
      globs     = ServiceGraphDev.configuration.service_globs
      all_files = globs.flat_map { |g| Dir.glob(g) }.uniq
      services  = {}
      file_contents = {}

      # Pass 1: collect class names and metadata
      all_files.each do |path|
        content = File.read(path, encoding: "utf-8", invalid: :replace, undef: :replace)
        file_contents[path] = content
        class_name = extract_class_name(content)
        next unless class_name

        services[class_name] = {
          class_name:   class_name,
          file:         relative_path(path),
          pack:         extract_pack(path),
          description:  extract_description(content),
          parent:       extract_parent(content),
          dependencies: [],
        }
      end

      known_classes = services.keys.to_set

      # Pass 2: detect dependencies by intersecting references with known classes
      all_files.each do |path|
        content    = file_contents[path]
        class_name = extract_class_name(content)
        next unless class_name && services[class_name]

        services[class_name][:dependencies] = extract_dependencies(content, known_classes, class_name)
      end

      {
        services:     services,
        generated_at: Time.current.iso8601,
        total:        services.size,
      }
    end

    private

    def relative_path(path)
      path.delete_prefix("#{Rails.root}/")
    end

    # Extracts the pack name from the file path.
    # packs/talent/evaluation_process/... → "talent/evaluation_process"
    # app/services/...                    → "app"
    def extract_pack(path)
      rel = relative_path(path)
      return "app" unless rel.start_with?("packs/")

      parts = rel.split("/")
      parts[1..2].join("/")
    end

    # Extracts the fully qualified class name, handling module wrappers.
    # E.g.: module Foo\n  class Bar  →  Foo::Bar
    def extract_class_name(content)
      modules = []
      content.each_line do |line|
        stripped = line.strip
        if (m = stripped.match(/\Amodule\s+([\w:]+)/))
          modules << m[1]
        elsif (m = stripped.match(/\Aclass\s+([\w:]+)/))
          return build_qualified_name(modules, m[1])
        end
      end
      nil
    end

    def extract_parent(content)
      content.each_line do |line|
        stripped = line.strip
        if (m = stripped.match(/\Aclass\s+[\w:]+\s*<\s*([\w:]+(?:::\w+)*)/))
          return m[1]
        end
      end
      nil
    end

    # Combines module namespace with class name, avoiding double prefixes.
    def build_qualified_name(modules, class_part)
      return class_part if modules.empty?

      full_module = modules.join("::")
      class_part.start_with?("#{full_module}::") ? class_part : "#{full_module}::#{class_part}"
    end

    # Extracts description from the comment block preceding the class declaration.
    # Ignores Sorbet/Rubocop directives and YARD tags like @param/@return.
    def extract_description(content)
      lines         = content.lines
      class_line_idx = lines.find_index { |l| l.strip.match?(/\Aclass\s/) }
      return "" unless class_line_idx

      comments = []
      (class_line_idx - 1).downto(0) do |i|
        line = lines[i].strip
        break if line.empty? && comments.any?
        next  if line.empty?

        if line.start_with?("#")
          stripped = line.sub(/^#+\s?/, "").strip
          next if stripped.start_with?("@")
          next if stripped.match?(/\A(typed:|frozen_string_literal)/)
          comments.unshift(stripped) unless stripped.empty?
        else
          break
        end
      end

      comments.reject(&:empty?).join(" ").presence || ""
    end

    # Detects dependencies by finding references to known classes in the file.
    def extract_dependencies(content, known_classes, self_class)
      references = content.scan(/\b([A-Z][A-Za-z0-9]*(?:::[A-Z][A-Za-z0-9]*)*)/).flatten.to_set
      (references & known_classes - Set[self_class]).to_a.sort
    end
  end
end
