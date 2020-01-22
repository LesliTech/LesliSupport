require_dependency "cloud_help/application_controller"

module CloudHelp
=begin

Lesli

Copyright (c) 2020, Lesli Technologies, S. A.

All the information provided by this website is protected by laws of Guatemala related 
to industrial property, intellectual property, copyright and relative international laws. 
Lesli Technologies, S. A. is the exclusive owner of all intellectual or industrial property
rights of the code, texts, trade mark, design, pictures and any other information.
Without the written permission of Lesli Technologies, S. A., any replication, modification,
transmission, publication is strictly forbidden.
For more information read the license file including with this software.

LesliCloud - Your Smart Business Assistant

Powered by https://www.lesli.tech
Building a better future, one line of code at a time.

@author   Carlos Hermosilla
@license  Propietary - all rights reserved.
@version  0.1.0-alpha
@description Controller for ticket workflows

=end
    class TicketWorkflowsController < ApplicationController
        before_action :set_ticket_workflow, only: [:update, :destroy]

=begin
@return [HTML|JSON] HTML view for listing all ticket workflows or a Json that contains a list 
    of all ticket workflows associated to this *account*
@description Retrieves and returns all ticket workflows associated to a *CloudHelp::Account*. 
    The account is obtained directly from *current_user*. The HTTP request has to specify
    wheter the HTML or the JSON text should be rendered
@example
    # Executing this controller's action from javascript's frontend
    this.http.get(`127.0.0.1/help/ticket_workflow`);
=end
        def index
            respond_to do |format|
                format.html {}
                format.json do 
                    ticket_workflows = TicketWorkflow.detailed_info(current_user.account)
                    responseWithSuccessful(ticket_workflows)
                end
            end
        end

=begin
@return [HTML|Json] HTML view showing the requested ticket workflow or a Json that contains the
    information of the ticket workflow. If there is an error, an explanation message is sent
@description Retrieves and returns the requested ticket workflow. The id of the 
    workflow is within the *params* attribute of the controller. The HTTP request has to specify
    wheter the HTML or the JSON text should be rendered
@example
    # Executing this controller's action from javascript's frontend
    let ticket_workflow_id = 1;
    this.http.get(`127.0.0.1/help/ticket_workflows/${ticket_workflow_id}`);
=end
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

=begin
@controller_action_param :name [String] The name of the new workflow
@controller_action_param :default [Boolean] A flag that marks this workflow as default or not
@controller_action_param :details_attributes [Array] Array of hashes, containing the information of the new attributes
@controller_action_param :details_attributes.next_states [String] Transitions to the next state. The format is 
    "[state_id]|[state_id]|..."
@controller_action_param :details_attributes.cloud_help_ticket_workflow_states_id [Integer] The id of the state associated
    to this detail
    
@return [Json] Json that contains wheter the creation of the workflow was successful or not. 
    If it is not successful, it returns an error message
@description Creates a new workflow associated to the *current_user*'s *account*
@example
    # Executing this controller's action from javascript's frontend
    let data = {
        ticket_workflow: {
            name: "Important",
            default: true,
            details_attributes: [
                {
                    cloud_help_ticket_workflow_states_id: 4,
                    next_states: "6"
                },{
                    cloud_help_ticket_workflow_states_id: 6,
                    next_states: null
                }
            ]
        }
    };
    this.http.post('127.0.0.1/help/ticket_workflows', data);
=end
        def create
            ticket_workflow = TicketWorkflow.new(ticket_workflow_params)
            ticket_workflow.cloud_help_accounts_id = current_user.account.id

            if ticket_workflow.save
                responseWithSuccessful(ticket_workflow)
            else
                responseWithError(ticket_workflow.errors.full_messages.to_sentence)
            end
        end

=begin
@return [HTML] HTML view for editing the ticket workflow
@description returns an HTML view with a form so users edit an existing ticket workflow
@example
    # Executing this controller's action from javascript's frontend
    let ticket_workflow_id = 3;
    this.url.go(`/help/ticket_workflows/${ticket_workflow_id}/edit`)
=end
        def edit
        end

=begin
@controller_action_param :cloud_help_slas_id [Integer] The id of the associated SLA
@controller_action_param :default [Boolean] Whether this workflow is the default workflow or not
@controller_action_param :detail_attributes [Array] Arary of hashes that represent the attributes
    of the workflow details
@controller_action_param :detail_attributes.id [Integer] The id of the detail
@controller_action_param :detail_attributes.next_states [String] A string of numbers, separated by '|'.
    Each number represents the id of a *CloudHelp::TicketState* and creates a valid transition. 
    A valid transition is a transition from one detail that has a state in its *next_states* attribute 
    to another detail, that has that state in its *ticket_state_id* attribute
@controller_action_param :detail_attributes.ticket_state_id [Integer] The id of the state associated to
    this workflow detail
@return [Json] Json that contains wheter the ticket workflow was successfully updated or not. 
    If it it not successful, it returns an error message
@description Updates an existing ticket workflow associated to the *current_user*'s *account*.
@example
    # Executing this controller's action from javascript's frontend
    let ticket_workflow_id = 4;
    let data = {
        ticket_workflow: {
            cloud_help_slas_id: 6,
            details_attributes: [
                {
                    id: 1,
                    next_states: '56|57',
                    ticket_state_id: 55
                }, {
                    id: 4,
                    next_states: null,
                    ticket_state_id: 56
                }, {
                    id: 5,
                    next_states: null,
                    ticket_state_id: 57
                }
            ]
        }
    };
    this.http.put(`127.0.0.1/help/ticket_workflows/${ticket_workflow_id}`, data);
=end
        def update
            workflow_params = ticket_workflow_params
            if workflow_params[:details_attributes]
                @ticket_workflow.replace_workflow(current_user.account, workflow_params[:details_attributes])
                workflow_params = workflow_params.except(:details_attributes)
            end

            @ticket_workflow.update(workflow_params)
            return responseWithError(@ticket_workflow.errors.full_messages.to_sentence) if @ticket_workflow.errors.any?
            responseWithSuccessful
        end

=begin
@return [Json] Json that contains wheter the workflow was successfully deleted or not. 
    If it it not successful, it returns an error message
@description Deletes an existing *workflow* associated to the *current_user*'s *account*.
    Since the workflow has details, these are also deleted. However, if there
    is an existing *cloud_object* associated to the *workflow*, it cannot be deleted
@example
    # Executing this controller's action from javascript's frontend
    let ticket_workflow_id = 4;
    this.http.delete(`127.0.0.1/help/ticket_types/${ticket_workflow_id}`);
=end
def destroy
    return responseWithNotFound unless @ticket_workflow

    if @ticket_workflow.destroy
        responseWithSuccessful
    else
        responseWithError(@ticket_workflow.errors.full_messages.to_sentence)
    end
end

        private

=begin
@return [void]
@description Sets the variable @ticket_workflow. The variable contains the *ticket* *workflow* 
    to be handled by the controller action that called this method
@example
    #suppose params[:id] = 1
    puts @ticket_workflow # will display nil
    set_ticket_workflow
    puts @ticket_workflow # will display an instance of CloudHelp:TicketWorkflow
=end
        def set_ticket_workflow
            @ticket_workflow = TicketWorkflow.find_by(
                id: params[:id],
                cloud_help_accounts_id: current_user.account.id
            )
        end

=begin
@return [Parameters] Allowed parameters for the ticket workflow
@description Sanitizes the parameters received from an HTTP call to only allow the specified ones.
    Allowed params are :cloud_help_slas_id, :default, details_attributes: [:id, :next_state, :ticket_state_id]
@example
    # supose params contains {
    #    ticket_workflow: {
    #       id: 5,
    #       name: "Workflow Name"
    #       default: false,
    #       details_attributes: [
    #            {
    #                id: 1,
    #                next_states: "4|5|6",
    #                name: "In use"
    #            }
    #        ]
    #    }
    #}
    filtered_params = ticket_workflow_params
    puts filtered_params
    # will remove the unpermitted params and only print {
    #       id: 5,
    #       default: false,
    #       details_attributes: [
    #            {
    #                id: 1,
    #                next_states: "4|5|6"
    #            }
    #        ]
    #    }
=end
        def ticket_workflow_params
            params.require(:ticket_workflow).permit(
                :name,
                :default,
                details_attributes: %i[id next_states cloud_help_ticket_workflow_states_id]
            )
        end

    end
end
