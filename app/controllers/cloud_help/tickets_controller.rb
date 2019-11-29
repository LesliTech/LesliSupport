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
            :api_transfer
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
                ticket.notify_followers("Ticket number #{ticket.id} has been created")
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
            old_workflow = @ticket.detail.workflow
            new_workflow = TicketWorkflow.find_by(
                id: params[:workflow_id],
                ticket_category: old_workflow.ticket_category,
                ticket_type: old_workflow.ticket_type
            )
            if new_workflow
                @ticket.detail.update(workflow: new_workflow)
                ticket_state = new_workflow.ticket_state
                responseWithSuccessful({state_id: ticket_state.id, state_name: ticket_state.name})
                @ticket.notify_followers("Ticket number #{@ticket.id} has been updated to state to #{ticket_state.name}")
            else
                responseWithError(I18n.t('cloud_help.controllers.tickets.errors.invalid_workflow_transition'))
            end
        end

        # PUT /tickets/1/escalate
        def api_escalate
            if @ticket.detail.workflow.ticket_state.is_final?
                responseWithError(I18n.t('cloud_help.controllers.tickets.errors.cannot_escalate_closed_ticket'))
            else
                if @ticket.escalate
                    priority = @ticket.detail.priority
                    responseWithSuccessful
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
                    priority = @ticket.detail.priority
                    responseWithSuccessful
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
                else
                    responseWithError(@ticket.errors.full_messages.to_sentence)
                end
            end
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
