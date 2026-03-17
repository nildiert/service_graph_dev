# frozen_string_literal: true

# ServiceGraphDev configuration
# Run `rails generate service_graph_dev:install` to create this file.

ServiceGraphDev.configure do |config|
  # Glob patterns to locate your service files.
  # Default: app/services/**/*.rb and packs/**/app/services/**/*.rb
  #
  # config.service_globs = [
  #   Rails.root.join("app/services/**/*.rb").to_s,
  #   Rails.root.join("packs/**/app/services/**/*.rb").to_s,
  # ]

  # How long (in seconds) the analysis cache lives.
  # Default: 300 (5 minutes)
  #
  # config.cache_ttl = 5 * 60

  # Rails environments where the engine is accessible.
  # Default: ["development"]
  #
  # config.allowed_environments = %w[development]
end
