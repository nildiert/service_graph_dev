# frozen_string_literal: true

require "rails/generators/base"

module ServiceGraphDev
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path("templates", __dir__)
      desc "Mounts ServiceGraphDev engine in config/routes.rb (development only) and creates an initializer."

      def mount_engine
        route_code = <<~RUBY.indent(2)
          if Rails.env.development?
            mount ServiceGraphDev::Engine, at: "/service_graph"
          end
        RUBY

        routes_file = File.join(destination_root, "config/routes.rb")

        if File.exist?(routes_file) && File.read(routes_file).include?("ServiceGraphDev::Engine")
          say_status :skip, "ServiceGraphDev engine is already mounted in config/routes.rb", :yellow
        else
          route route_code.strip
        end
      end

      def copy_initializer
        template "initializer.rb", "config/initializers/service_graph_dev.rb"
      end
    end
  end
end
