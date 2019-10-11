require_dependency "cloud_help/application_controller"

module CloudHelp
    class Api::TicketController < ApplicationController
        def index
            tickets = Ticket.all
            responseWithSuccessful(tickets)
        end
    end
end
