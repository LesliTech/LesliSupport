require_dependency "cloud_help/application_controller"

module CloudHelp
  class Ticket::TimelinesController < ApplicationController
    before_action :set_ticket_timelines, only: [:index]

    # GET /ticket/1/timelines
    def index
        responseWithSuccessful(@ticket_timelines)
    end

    private

    # Setting up the ticket timeline
    def set_ticket_timelines
        ticket_id = params[:ticket_id]
        @ticket_timelines = current_user.account.help.tickets.find(ticket_id).timelines
    end

  end
end
