require_dependency "cloud_help/application_controller"

module CloudHelp
    class TicketWorkflowsController < ApplicationController
        before_action :set_ticket_workflow, only: [:update, :destroy]

        # GET /ticket_workflow/assignments
        def index
            respond_to do |format|
                format.html {}
                format.json do 
                    ticket_workflows = TicketWorkflow.detailed_info(current_user.account)
                    responseWithSuccessful(ticket_workflows)
                end
            end
        end

        # GET /ticket_workflows/1
        def show
            respond_to do |format|
                format.html {}
                format.json do
                    set_ticket_workflow
                    if @ticket_workflow
                        responseWithSuccessful(@ticket_workflow.full_workflow)
                    else
                        responseWithError(I18n.t('cloud_help.controllers.ticket_workflows.errors.not_found'))
                    end
                end
            end
        end

        # GET /ticket_workflows/1/edit
        def edit
        end

        # PATCH/PUT /ticket_workflows/1
        def update
            @ticket_workflow.replace_workflow(current_user.account, ticket_workflow_params[:details_attributes])
            if ticket_workflow_params[:cloud_help_slas_id]
                @ticket_workflow.update(cloud_help_slas_id: ticket_workflow_params[:cloud_help_slas_id])
            end
            
            return responseWithError(@ticket_workflow.errors.full_messages.to_sentence) if @ticket_workflow.errors.any?

            responseWithSuccessful
        end

        private

        # We join with cloud_help_slas to verify the account
        def set_ticket_workflow
            @ticket_workflow = TicketWorkflow.joins(
                :sla
            ).where(
                id: params[:id]
            ).where(
                "cloud_help_slas.cloud_help_accounts_id = #{current_user.account.id}"
            ).first
        end

        # Only allow a trusted parameter "white list" through.
        def ticket_workflow_params
            params.require(:ticket_workflow).permit(
                :cloud_help_slas_id,
                details_attributes: %i[id next_states ticket_state_id]
            )
        end

    end
end
