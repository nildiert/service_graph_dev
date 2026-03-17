# frozen_string_literal: true

require "rails"

module ServiceGraphDev
  class Engine < ::Rails::Engine
    isolate_namespace ServiceGraphDev

    initializer "service_graph_dev.load_config" do
      # Ensures configuration is available during initialization.
    end
  end
end
