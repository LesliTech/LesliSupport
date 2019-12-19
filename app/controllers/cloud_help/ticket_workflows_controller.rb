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
                        responseWithSuccessful(@ticket_workflow.full_workflow(current_user.account))
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
            if @ticket_workflow.replace_workflow(current_user.account, ticket_workflow_params)
                responseWithSuccessful
            else
                responseWithError(@ticket_workflow.errors.full_messages.to_sentence)
            end
        end

        private

        # Ticket Workflow Id is the ID of the first node of the workflow (CREATED)
        def set_ticket_workflow
            @ticket_workflow = TicketWorkflow.find_by(id: params[:id])
        end

        # Only allow a trusted parameter "white list" through.
        def ticket_workflow_params
            filtered_params = []
            params.require(:ticket_workflow).each do |unfiltered_params|
                filtered_params.push(unfiltered_params.permit(
                    :id,
                    :ticket_state_id,
                    :next_states,
                    :cloud_help_slas_id
                ))
            end
            filtered_params
        end

    end
end
