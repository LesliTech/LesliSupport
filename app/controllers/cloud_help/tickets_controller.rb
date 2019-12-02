require_dependency "cloud_help/application_controller"

module CloudHelp
    class TicketsController < ApplicationController
        before_action :set_ticket, only: [
            :update,
            :discussions,
            :actions,
            :files,
            :activities,
            :api_follow_up_states,
            :api_update_workflow,
            :api_escalate,
            :api_descalate,
            :api_transfer,
            :api_timelines
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
                    ticket = Ticket.find_by(
                        id: params[:id],
                        account: current_user.account.help
                    ).detailed_info
                    responseWithSuccessful(ticket)
                end
            end
        end

        # GET /tickets/new
        def new
        end

        # GET /tickets/1/edit
        def edit
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
                ticket.add_follower(current_user)
                ticket.notify_followers(I18n.t('cloud_help.controllers.tickets.notifications.created', ticket_id: ticket.id))
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

        # GET /tickets/options
        def api_options
            account = current_user.account
            responseWithSuccessful({
                types: TicketType.where(account: current_user.account.help).select(:id, :name),
                categories: TicketCategory.tree(account),
                priorities: TicketPriority.where(account: current_user.account.help).select(:id, :name)
            })
        end

        # GET /tickets/1/follow_up_states
        def api_follow_up_states
            responseWithSuccessful(@ticket.detail.workflow.follow_up_states)
        end

        # PUT /tickets/1/workflow
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
                @ticket.notify_followers(I18n.t(
                    'cloud_help.controllers.tickets.notifications.updated.workflow',
                    ticket_id: @ticket.id,
                    state_name: new_workflow_node.ticket_state.name
                ))
            else
                responseWithError(@ticket.errors.full_messages.to_sentence)
            end
        end

        # PUT /tickets/1/escalate
        def api_escalate
            if @ticket.detail.workflow.ticket_state.is_final?
                responseWithError(I18n.t('cloud_help.controllers.tickets.errors.cannot_escalate_closed_ticket'))
            else
                if @ticket.escalate
                    ticket_priority = @ticket.detail.priority
                    responseWithSuccessful
                    @ticket.notify_followers(I18n.t(
                        'cloud_help.controllers.tickets.notifications.updated.escalated',
                        ticket_id: @ticket.id,
                        priority_name: ticket_priority.name
                    ))
                else
                    responseWithError(@ticket.errors.full_messages.to_sentence)
                end
            end
        end

        # PUT /tickets/1/descalate
        def api_descalate
            if @ticket.detail.workflow.ticket_state.is_final?
                responseWithError(I18n.t('cloud_help.controllers.tickets.errors.cannot_descalate_closed_ticket'))
            else
                if @ticket.descalate
                    ticket_priority = @ticket.detail.priority
                    responseWithSuccessful
                    @ticket.notify_followers(I18n.t(
                        'cloud_help.controllers.tickets.notifications.updated.descalated',
                        ticket_id: @ticket.id,
                        priority_name: ticket_priority.name
                    ))
                else
                    responseWithError(@ticket.errors.full_messages.to_sentence)
                end
            end
        end

        def api_transfer
            if @ticket.detail.workflow.ticket_state.is_final?
                responseWithError(I18n.t('cloud_help.controllers.tickets.errors.cannot_transfer_closed_ticket'))
            else
                if @ticket.transfer(current_user.account.help, params[:cloud_help_ticket_types_id], params[:cloud_help_ticket_categories_id])
                    responseWithSuccessful
                    ticket_category = @ticket.detail.category
                    ticket_type = @ticket.detail.type
                    @ticket.notify_followers(I18n.t(
                        'cloud_help.controllers.tickets.notifications.updated.transferred',
                        ticket_id: @ticket.id,
                        type_name: ticket_type.name,
                        category_name: ticket_category.name
                    ))
                else
                    responseWithError(@ticket.errors.full_messages.to_sentence)
                end
            end
        end

        def api_timelines
            responseWithSuccessful(@ticket.timelines)
        end

        private

        def set_ticket
            ticket_id = params[:id] unless params[:id].blank?
            ticket_id = params[:ticket_id] unless params[:ticket_id].blank?
            @ticket = current_user.account.help.tickets.find(ticket_id)
        end

        # Only allow a trusted parameter "white list" through.
        def ticket_params
            params.require(:ticket).permit(
                detail_attributes: [
                    :id,
                    :subject,
                    :description,
                    :tags,
                    :cloud_help_ticket_types_id,
                    :cloud_help_ticket_priorities_id,
                    :cloud_help_ticket_categories_id
                ]
            )
        end

    end
end
