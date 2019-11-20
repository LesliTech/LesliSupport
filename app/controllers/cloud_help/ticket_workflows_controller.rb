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
            if @states_action.update(states_action_params)
                responseWithSuccessful(@states_action)
            else
                responseWithError("Action not updated")
            end
        end

        private

        # Ticket Workflow Id is the ID of the first node of the workflow (CREATED)
        def set_ticket_workflow
            @ticket_workflow = TicketWorkflow.find_by(id: params[:id])
        end

        # Only allow a trusted parameter "white list" through.
        def states_action_params
            params.require(:states_action).permit(:id, :type, :instructions, :deadline, :complete, :tags, :cloud_help_statess_id)
        end

    end
end
