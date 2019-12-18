require_dependency "cloud_help/application_controller"

module CloudHelp
    class Ticket::SubscribersController < ApplicationController

        # GET /tickets/1/subscribers
        # Returns all possible subscribers
        def index
            ticket = current_user.account.help.tickets.find(params[:ticket_id])
            responseWithSuccessful(ticket.subscription_events(current_user))
        end

    end
end
