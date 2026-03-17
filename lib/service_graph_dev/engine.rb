# frozen_string_literal: true

require "rails"

module ServiceGraphDev
  class Engine < ::Rails::Engine
    isolate_namespace ServiceGraphDev

    initializer "service_graph_dev.load_config" do
      # Ensures configuration is available during initialization.
    end

    # Auto-monta el engine en /service_graph si el environment está permitido.
    # Esto evita que el usuario tenga que modificar config/routes.rb manualmente.
    # Se puede desactivar con:
    #   ServiceGraphDev.configure { |c| c.auto_mount = false }
    initializer "service_graph_dev.auto_mount", after: :finisher_hook do |app|
      next unless ServiceGraphDev.configuration.auto_mount

      allowed = ServiceGraphDev.configuration.allowed_environments
      next unless allowed.include?(Rails.env)

      mount_path = ServiceGraphDev.configuration.mount_path

      already_mounted = app.routes.routes.any? do |route|
        route.app.respond_to?(:app) && route.app.app == ServiceGraphDev::Engine
      end

      unless already_mounted
        app.routes.append do
          mount ServiceGraphDev::Engine, at: mount_path
        end
      end
    end
  end
end
