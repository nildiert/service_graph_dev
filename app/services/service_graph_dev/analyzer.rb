# frozen_string_literal: true

require_relative "../../vendor/kaskd/lib/kaskd"

module ServiceGraphDev
  # Thin wrapper around Kaskd::Analyzer that adds Rails.cache integration
  # and translates ServiceGraphDev configuration into Kaskd.
  #
  # All core analysis logic lives in Kaskd (vendor/kaskd — git submodule).
  # This class is responsible only for:
  #   - Bridging ServiceGraphDev.configuration.service_globs into Kaskd
  #   - Wrapping results with Rails.cache for the configured TTL
  #   - Providing the invalidate_cache convenience method used by the controller
  class Analyzer
    CACHE_KEY = "service_graph_dev/v3"

    def self.analyze_cached
      ttl = ServiceGraphDev.configuration.cache_ttl
      Rails.cache.fetch(CACHE_KEY, expires_in: ttl) { new.analyze }
    end

    def self.invalidate_cache
      Rails.cache.delete(CACHE_KEY)
    end

    def analyze
      globs  = ServiceGraphDev.configuration.service_globs
      kaskd  = Kaskd::Analyzer.new(root: Rails.root.to_s, globs: globs)
      kaskd.analyze
    end
  end
end
