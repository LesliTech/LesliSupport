require_dependency "cloud_help/application_controller"

module CloudHelp
    class TicketsController < ApplicationController
        #before_action :set_ticket, only: [:show, :edit, :update, :destroy]
        before_action :set_ticket, except: [:index]

        # GET /tickets
        def index
            tickets = current_user.account.help.ticket.joins(:detail).select(:id, :subject, :created_at, :updated_at)
            respond_to do |format|
                format.html
                format.json { responseWithSuccessful(tickets) }
            end
        end

        # GET /tickets/1
        def show
            ticket =  current_user.account.help.ticket
                .joins(:detail)
                .select(:id, :subject, :description, :created_at, :updated_at)
                .find(@ticket.id)
            responseWithSuccessful(ticket)
        end

        # GET /tickets/new
        def new
            @ticket = Ticket.new
        end

        # GET /tickets/1/edit
        def edit
        end

        # POST /tickets
        def create

            ticket = Ticket.new(ticket_params)

            ticket.cloud_help_accounts_id = current_user.account.id

            if ticket.save
                responseWithSuccessful(ticket)
            else
                responseWithError("error creating new ticket", ticket.errors.full_messages)
            end

        end

        # PATCH/PUT /tickets/1
        def update
            if @ticket.update(ticket_params)
                responseWithSuccessful(@ticket)
                CloudBell::NotificationsController.web_notification
            else
                render :edit
            end
        end

        # DELETE /tickets/1
        def destroy
            @ticket.destroy
            redirect_to tickets_url, notice: 'Ticket was successfully destroyed.'
        end

        def discussions
            ticket_discussions = @ticket.discussion
            responseWithSuccessful(ticket_discussions)
        end

        def actions
            ticket_actions = @ticket.actions
            responseWithSuccessful(ticket_actions)
        end

        private

        def set_ticket
            ticket_id = params[:id] unless params[:id].blank?
            ticket_id = params[:ticket_id] unless params[:ticket_id].blank?
            @ticket = current_user.account.help.ticket.find(ticket_id)
        end

        # Only allow a trusted parameter "white list" through.
        def ticket_params
            params.require(:ticket).permit(
                detail_attributes: [
                    :id,
                    :subject,
                    :description
                ]
            )
        end

    end
end
