require_dependency "cloud_help/application_controller"

module CloudHelp
    class TicketsController < ApplicationController

        before_action :set_ticket, only: [
            :update,
            :activities,
            :api_follow_up_states
        ]

        # GET /tickets
        def index
            respond_to do |format|
                format.html { }
                format.json do
                    tickets = Ticket.detailed_info(current_user.account.help)
                    responseWithSuccessful(tickets) 
                end
            end
        end

        # GET /tickets/1
        def show
            respond_to do |format|
                format.html { }
                format.json do
                    set_ticket
                    responseWithSuccessful(@ticket.detailed_info)
                end
            end
        end

        # GET /tickets/new
        def new
        end

        # GET /tickets/1/edit
        def edit
        end

        # PUT|PATCH /tickets/1
        def update
            if @ticket.update(ticket_params)
                responseWithSuccessful(@ticket.detailed_info)
            else
                responseWithError(@ticket.errors.full_messages.to_sentence)
            end
        end

        # POST /tickets
        def create
            ticket = Ticket.new(ticket_params)
            ticket.user = current_user
            ticket.account = current_user.account.help
            ticket.detail.source = TicketSource.cloud_help_source
            ticket.set_workflow_detail

            if ticket.save
                responseWithSuccessful(ticket)
                Ticket::Subscriber.add_subscriber(ticket, current_user)
                Ticket::Subscriber.notify_subscribers(
                    ticket,
                    I18n.t('cloud_help.controllers.tickets.notifications.created', ticket_id: ticket.id),
                    :ticket_created
                )
            else
                responseWithError(@ticket.errors.full_messages.to_sentence)
            end
        end

        # GET /tickets/1/activities
        def activities
            responseWithSuccessful([])
        end

        # GET /api/tickets/options
        def api_options
            account = current_user.account
            responseWithSuccessful({
                types: TicketType.where(account: current_user.account.help).select(:id, :name),
                categories: TicketCategory.tree(account),
                priorities: TicketPriority.where(account: current_user.account.help).select(:id, :name, :weight)
            })
        end

        # GET /api/tickets/1/follow_up_states
        def api_follow_up_states
            responseWithSuccessful(@ticket.detail.workflow_detail.follow_up_states)
        end

        private

        # Setting up the ticket
        def set_ticket
            ticket_id = params[:id] unless params[:id].blank?
            ticket_id = params[:ticket_id] unless params[:ticket_id].blank?
            @ticket = current_user.account.help.tickets.find(ticket_id)
        end
        
        # Setting up the white list for tickets
        def ticket_params
            params.require(:ticket).permit(
                detail_attributes: [
                    :id,
                    :subject,
                    :description,
                    :tags,
                    :deadline,
                    :cloud_help_ticket_types_id,
                    :cloud_help_ticket_priorities_id,
                    :cloud_help_ticket_categories_id,
                    :cloud_help_ticket_workflow_details_id
                ],
                assignment_attributes: [
                    :users_id,
                    :cloud_teams_teams_id,
                    :assignation_type
                ]
            )
        end

    end
end
