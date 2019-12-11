require_dependency "cloud_help/application_controller"

module CloudHelp
    class Ticket::AssignmentsController < ApplicationController

        # GET /ticket/assignments
        # Shows all possible assignables to this ticket
        def index
            responseWithSuccessful(Courier::Core::Users.list())
        end
    end
end
