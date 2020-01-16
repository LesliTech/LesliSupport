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
@description Controller for ticket assignments

=end
    class Ticket::AssignmentsController < ApplicationController
        before_action :set_ticket_assignment, only: [:show, :update]

=begin
@return [Json] Json that contains the information of the ticket assignment. 
    If there is an error, an explanation message is sent
@description Retrieves and returns the requested ticket assignment. The id of the 
    ticket is within the *params* attribute of the controller. The HTTP request has to specify
    wheter the HTML or the JSON text should be rendered
@example
    # Executing this controller's action from javascript's frontend
    let ticket_id = 1;
    this.http.get(`127.0.0.1/help/tickets/${ticket_id}/assignment`);
=end
def show
    if @ticket_assignment
        responseWithSuccessful(@ticket_assignment)
    else
        responseWithSuccessful
    end
end

=begin
@controller_action_param :users_id [Integer] The id of the user
@controller_action_param :cloud_teams_team_id [Integer] The id of the team
@controller_action_param :assignation_type [String] A string representing a valid assignation_type.
@return [Json] Json that contains wheter the creation of the asignment was successful or not. 
    If it is not successful, it returns an error message
@description Creates a new assignment associated to a *ticket*
@example
    # Executing this controller's action from javascript's frontend
    let ticket_id = 1;
    let data = {
        assignment: {
            assignation_type: "user",
            users_id: 1
        }
    };
    this.http.post('127.0.0.1/help/tickets/${ticket_id}/assignment', data);
=end
        def create
            ticket = CloudHelp::Ticket.find_by(
                id: params[:ticket_id],
                cloud_help_accounts_id: current_user.account.id
            )
            if ticket.create_assignment(ticket_assignment_params)
                responseWithSuccessful(ticket.assignment)
            else
                responseWithError(ticket.error.full_messages.to_sentece)
            end
        end

=begin
@controller_action_param :users_id [Integer] The id of the user
@controller_action_param :cloud_teams_team_id [Integer] The id of the team
@controller_action_param :assignation_type [String] A string representing a valid assignation_type.
@return [Json] Json that contains wheter the update of the asignment was successful or not. 
    If it is not successful, it returns an error message
@description Updates an assignment associated to a *ticket*. The id of the ticket is
    in the *:ticket_id* attribute of the *params* hash.
@example
    # Executing this controller's action from javascript's frontend
    let ticket_id = 1;
    let data = {
        assignment: {
            assignation_type: "user",
            users_id: 1
        }
    };
    this.http.put('127.0.0.1/help/tickets/${ticket_id}/assignment', data);
=end
        def update
            return responseWithNotFound unless @ticket_assignment

            if @ticket_assignment.update(ticket_assignment_params)
                responseWithSuccessful(@ticket_assignment)
            else
                responseWithError(ticket.error.full_messages.to_sentece)
            end
        end
        
=begin
@return [JSON] Json that contains a list of all users to wich a ticket can be assigned to.
@description Comunicates to the core using the *Courier* engine to retrieve a list of all the
    possible users a ticket can be assigned to.
@example
    possible_users = Courier::Core::Users.list
=end
        def assignment_options
            responseWithSuccessful(Courier::Core::Users.list)
        end

        private

=begin
@return [void]
@description Sets the variable @ticket_assignment. The variable contains the *ticket* *assignment* 
    to be handled by the controller action that called this method
@example
    #suppose params[:ticket_id] = 1
    puts @ticket_assignment # will display nil
    set_ticket_assignment
    puts @ticket_assignment # will display an instance of CloudHelp:Ticket::Assignment
=end
        def set_ticket_assignment
            @ticket_assignment = CloudHelp::Ticket::Assignment.joins(:ticket).find_by(
                "cloud_help_tickets.id = #{params[:ticket_id]}",
                "cloud_help_tickets.cloud_help_accounts_id = #{current_user.account.id}"
            )
        end

=begin
@return [Parameters] Allowed parameters for the ticket state
@description Sanitizes the parameters received from an HTTP call to only allow the specified ones.
    Allowed params are :users_id, :cloud_team_teams_id, :assignation_type
@example
    # supose params contains {
    #    "assignment": {
    #        "id": 5,
    #        "name": "Reviewing Changes",
    #        "users_id": 4,
    #        "assignation_type": "user"
    #    }
    #}
    filtered_params = assignment_params
    puts filtered_params
    # will remove the id and only print {
    #    "users_id": 4,
    #    "assignation_type": "user"
    #}
=end
        def ticket_assignment_params
            params.fetch(:assignment, {}).permit(:users_id, :cloud_team_teams_id, :assignation_type)
        end
    end
end
