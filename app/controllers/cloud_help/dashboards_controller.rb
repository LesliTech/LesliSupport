require_dependency "cloud_help/application_controller"

module CloudHelp
    class DashboardsController < ApplicationController
        before_action :set_dashboard, only: [:show]

        def default
        end
        
    end
end
