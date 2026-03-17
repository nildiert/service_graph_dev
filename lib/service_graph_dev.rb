# frozen_string_literal: true

require "service_graph_dev/version"
require "service_graph_dev/configuration"
require "service_graph_dev/engine"

module ServiceGraphDev
  class << self
    def configuration
      @configuration ||= Configuration.new
    end

    # Configure the engine:
    #
    #   ServiceGraphDev.configure do |c|
    #     c.service_globs = [Rails.root.join("app/services/**/*.rb").to_s]
    #     c.cache_ttl     = 10.minutes
    #     c.allowed_environments = %w[development staging]
    #   end
    def configure
      yield configuration
    end
  end
end
