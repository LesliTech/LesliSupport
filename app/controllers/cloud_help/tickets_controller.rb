require_dependency "cloud_help/application_controller"

module CloudHelp
    class TicketsController < ApplicationController

        before_action :set_ticket, only: [
            :discussions,
            :actions,
            :files,
            :activities,
            :api_follow_up_states,
            :api_update_workflow,
            :api_escalate,
            :api_descalate,
            :api_transfer,
            :update
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
            ticket.set_workflow

            if ticket.save
                responseWithSuccessful(ticket)
                ticket.add_subscriber(current_user)
                ticket.notify_subscribers(
                    I18n.t('cloud_help.controllers.tickets.notifications.created', ticket_id: ticket.id),
                    :ticket_created
                )
            else
                responseWithError(@ticket.errors.full_messages.to_sentence)
            end
        end

        # GET /tickets/1/discussions
        def discussions
            ticket_discussions = @ticket.discussions.order(id: :desc)
            responseWithSuccessful(ticket_discussions)
        end

        # GET /tickets/1/actions
        def actions
            ticket_actions = @ticket.actions
            responseWithSuccessful(ticket_actions)
        end

        # GET /tickets/1/files
        def files
            ticket_files = @ticket.files
            responseWithSuccessful(ticket_files)
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
                priorities: TicketPriority.where(account: current_user.account.help).select(:id, :name)
            })
        end

        # GET /api/tickets/1/follow_up_states
        def api_follow_up_states
            responseWithSuccessful(@ticket.detail.workflow.follow_up_states)
        end

        # PUT /api/tickets/1/workflow
        def api_update_workflow
            old_workflow_node = @ticket.detail.workflow
            new_workflow_node = TicketWorkflow.find_by(
                id: params[:workflow_id],
                ticket_category: old_workflow_node.ticket_category,
                ticket_type: old_workflow_node.ticket_type
            )
            unless new_workflow_node
                return responseWithError(I18n.t('cloud_help.controllers.tickets.errors.invalid_workflow_transition'))
            end
            if @ticket.update_workflow(new_workflow_node)
                responseWithSuccessful(new_workflow_node.ticket_state)
                if new_workflow_node.ticket_state.is_final?
                    message = I18n.t( 'cloud_help.controllers.tickets.notifications.closed', ticket_id: @ticket.id )
                    @ticket.notify_subscribers(message, :ticket_closed)
                else
                    message = I18n.t(
                        'cloud_help.controllers.tickets.notifications.updated.workflow',
                        ticket_id: @ticket.id,
                        state_name: new_workflow_node.ticket_state.name
                    )
                    @ticket.notify_subscribers(message, :workflow_updated)
                end
            else
                responseWithError(@ticket.errors.full_messages.to_sentence)
            end
        end

        # PUT /api/tickets/1/escalate
        def api_escalate
            if @ticket.detail.workflow.ticket_state.is_final?
                responseWithError(I18n.t('cloud_help.controllers.tickets.errors.cannot_escalate_closed_ticket'))
            else
                if @ticket.escalate
                    ticket_priority = @ticket.detail.priority
                    responseWithSuccessful
                    message = I18n.t(
                        'cloud_help.controllers.tickets.notifications.updated.escalated',
                        ticket_id: @ticket.id,
                        priority_name: ticket_priority.name
                    )
                    @ticket.notify_subscribers(message, :priority_updated)
                else
                    responseWithError(@ticket.errors.full_messages.to_sentence)
                end
            end
        end

        # PUT /api/tickets/1/descalate
        def api_descalate
            if @ticket.detail.workflow.ticket_state.is_final?
                responseWithError(I18n.t('cloud_help.controllers.tickets.errors.cannot_descalate_closed_ticket'))
            else
                if @ticket.descalate
                    ticket_priority = @ticket.detail.priority
                    responseWithSuccessful
                    message = I18n.t(
                        'cloud_help.controllers.tickets.notifications.updated.descalated',
                        ticket_id: @ticket.id,
                        priority_name: ticket_priority.name
                    )
                    @ticket.notify_subscribers(message, :priority_updated)
                else
                    responseWithError(@ticket.errors.full_messages.to_sentence)
                end
            end
        end

        # PUT /api/tickets/1/transfer
        def api_transfer
            if @ticket.detail.workflow.ticket_state.is_final?
                responseWithError(I18n.t('cloud_help.controllers.tickets.errors.cannot_transfer_closed_ticket'))
            else
                if @ticket.transfer(current_user.account.help, params[:cloud_help_ticket_types_id], params[:cloud_help_ticket_categories_id])
                    responseWithSuccessful
                    ticket_category = @ticket.detail.category
                    ticket_type = @ticket.detail.type
                    message = I18n.t(
                        'cloud_help.controllers.tickets.notifications.updated.transferred',
                        ticket_id: @ticket.id,
                        type_name: ticket_type.name,
                        category_name: ticket_category.name
                    )
                    @ticket.notify_subscribers(message, :type_category_updated)
                else
                    responseWithError(@ticket.errors.full_messages.to_sentence)
                end
            end
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
            accepted_params = params.require(:ticket).permit(
                detail_attributes: [
                    :id,
                    :subject,
                    :description,
                    :tags,
                    :deadline,
                    :cloud_help_ticket_types_id,
                    :cloud_help_ticket_priorities_id,
                    :cloud_help_ticket_categories_id
                ],
                subscribers_attributes: [
                    :event,
                    :notification_type,
                    :id,
                    :_destroy
                ],
                assignment_attributes: [
                    :users_id,
                    :cloud_teams_teams_id,
                    :assignation_type
                ]
            )
            if accepted_params[:subscribers_attributes]
                accepted_params[:subscribers_attributes].each do |attributes|
                    attributes[:users_id] = current_user.id
                end
            end
            accepted_params
        end

    end
end
