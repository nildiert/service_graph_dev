# frozen_string_literal: true

module ServiceGraphDev
  class Configuration
    # Globs used to discover service files. Each entry is an absolute path pattern.
    # Defaults pick up app/services and packs/**/app/services (Packwerk layout).
    attr_accessor :service_globs

    # How long to cache analysis results (in seconds). Default: 5 minutes.
    attr_accessor :cache_ttl

    # Rails environments where the engine is accessible. Default: ["development"].
    attr_accessor :allowed_environments

    def initialize
      @service_globs = [
        Rails.root.join("app/services/**/*.rb").to_s,
        Rails.root.join("packs/**/app/services/**/*.rb").to_s,
      ]
      @cache_ttl = 5 * 60
      @allowed_environments = %w[development]
    end
  end
end
