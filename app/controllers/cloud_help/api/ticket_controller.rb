require_dependency "cloud_help/application_controller"

module CloudHelp
    class Api::TicketController < ApplicationController
        def index
            tickets = Ticket.joins(:detail).select(:id, :subject, :created_at, :updated_at)
            responseWithSuccessful(tickets)
        end
    end
end
