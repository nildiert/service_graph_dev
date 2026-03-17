# frozen_string_literal: true

module ServiceGraphDev
  class GraphsController < ActionController::Base
    before_action :require_allowed_environment!
    skip_forgery_protection only: :vis_network_js

    def show
      render layout: false
    end

    def data
      render json: Analyzer.analyze_cached
    end

    def refresh
      Analyzer.invalidate_cache
      render json: Analyzer.analyze_cached
    end

    # Sirve vis-network.min.js embebido en la gema para evitar dependencia de CDN externo.
    # Esto elimina problemas con Content-Security-Policy.
    def vis_network_js
      js_path = File.join(ServiceGraphDev::Engine.root, "vendor/assets/javascripts/vis-network.min.js")
      expires_in 1.year, public: true
      send_file js_path, type: "application/javascript", disposition: "inline"
    end

    private

    def require_allowed_environment!
      allowed = ServiceGraphDev.configuration.allowed_environments
      return if allowed.include?(Rails.env.to_s)

      head :not_found
    end
  end
end
