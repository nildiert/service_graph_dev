# frozen_string_literal: true

module ServiceGraphDev
  class GraphsController < ActionController::Base
    before_action :require_allowed_environment!

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

    private

    def require_allowed_environment!
      allowed = ServiceGraphDev.configuration.allowed_environments
      return if allowed.include?(Rails.env.to_s)

      head :not_found
    end
  end
end
