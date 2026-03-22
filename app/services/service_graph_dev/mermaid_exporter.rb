# frozen_string_literal: true

module ServiceGraphDev
  # Generates Mermaid flowchart strings from the services dependency graph.
  class MermaidExporter
    def initialize(services, selected, max_depth: 3, active_pack: nil)
      @services    = services
      @selected    = selected
      @max_depth   = max_depth
      @active_pack = active_pack
    end

    def export
      return "" if @selected.blank? || @services[@selected].nil?

      affected, affected_prev = compute_affected
      deps, deps_prev         = compute_deps

      lines = ["graph TD"]
      
      all_nodes = (Set.new([@selected]) + affected.keys + deps.keys).to_a.sort

      lines << "  %% Styles"
      lines << "  classDef default fill:#161b22,stroke:#30363d,color:#e6edf3,font-family:monospace"
      lines << "  classDef selected fill:#f0f6fc,stroke:#30a14e,stroke-width:2px,color:#0d1117"
      lines << "  classDef affected fill:#bd561d,stroke:#ffa657,color:#ffffff"
      lines << "  classDef dependency fill:#1f6feb,stroke:#79c0ff,color:#ffffff"

      all_nodes.each do |n|
        cls = if n == @selected
                "selected"
              elsif affected.key?(n)
                "affected"
              elsif deps.key?(n)
                "dependency"
              else
                "default"
              end
        lines << "  #{id(n)}[\"#{n}\"]:::#{cls}"
      end

      lines << ""
      lines << "  %% Edges"

      # Affected (above)
      affected.each do |n, _|
        parent = affected_prev[n] || @selected
        lines << "  #{id(n)} --> #{id(parent)}"
      end

      # Dependencies (below)
      deps.each do |n, _|
        parent = deps_prev[n] || @selected
        lines << "  #{id(parent)} --> #{id(n)}"
      end

      lines.join("\n")
    end

    private

    def id(name)
      name.gsub("::", "_")
    end

    def compute_affected
      rev_index = build_rev_index
      bfs(@selected, ->(n) { rev_index[n] })
    end

    def compute_deps
      bfs(@selected, ->(n) { @services[n]&.dig(:dependencies) })
    end

    def build_rev_index
      idx = {}
      @services.values.each do |s|
        (s[:dependencies] || []).each do |dep|
          (idx[dep] ||= []) << s[:class_name]
        end
      end
      idx
    end

    def bfs(start_name, neighbors_fn)
      dist = {}
      prev = {}
      queue = [start_name]
      dist[start_name] = 0

      while queue.any?
        cur = queue.shift
        next if dist[cur] >= @max_depth

        (neighbors_fn.call(cur) || []).each do |nb|
          next unless pack_filter_match?(nb)
          
          if dist[nb].nil?
            dist[nb] = dist[cur] + 1
            prev[nb] = cur
            queue << nb
          end
        end
      end

      dist.delete(start_name)
      prev.delete(start_name)
      [dist, prev]
    end

    def pack_filter_match?(name)
      return true if @active_pack.blank?
      @services[name]&.dig(:pack) == @active_pack
    end
  end
end
