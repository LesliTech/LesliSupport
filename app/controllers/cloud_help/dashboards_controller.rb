require_dependency "cloud_help/application_controller"

module CloudHelp
    class DashboardsController < ApplicationController
        before_action :set_dashboard, only: [:show, :edit, :update, :destroy]

        def show
        end

        private
        
        # Use callbacks to share common setup or constraints between actions.
        def set_dashboard
        end

        # Only allow a trusted parameter "white list" through.
        def dashboard_params
            params.fetch(:dashboard, {})
        end
    end
end
