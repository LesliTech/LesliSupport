require_dependency "cloud_help/application_controller"

module CloudHelp
=begin

Copyright (c) 2020, all rights reserved.

All the information provided by this platform is protected by international laws related  to 
industrial property, intellectual property, copyright and relative international laws. 
All intellectual or industrial property rights of the code, texts, trade mark, design, 
pictures and any other information belongs to the owner of this platform.

Without the written permission of the owner, any replication, modification,
transmission, publication is strictly forbidden.

For more information read the license file including with this software.

// · ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~
// · 

=end
    class Ticket::AssignmentsController < ApplicationController
        before_action :set_ticket, only: [:create, :destroy]

=begin
@return [HTML|JSON] HTML view for listing all assignments of an ticket or a Json that contains a list of 
    all assignments associated to certain ticket 
@description Retrieves and returns all ticket assignments associated to a *ClouHelp::Account* and a
    *CloudHelp::Ticket*. The account is obtained directly from *current_user*. The HTTP request has to specify
    wheter the HTML or the JSON text should be rendered
@example
    # Executing this controller's action from javascript's frontend
    let ticket_id: 1;
    this.http.get(`127.0.0.1/help/tickets/${ticket_id}/assignments`);
=end
        def index
            respond_to do |format|
                format.html {}
                format.json do
                    set_ticket
                    return respond_with_not_found unless @ticket

                    respond_with_successful(@ticket.assignments_list) 
                end
            end
        end

=begin
@controller_action_param :users_id [Integer] The id of the user that is going to be added as an assignment
@return [Json] Json that contains wheter the creation of the assignment was successful or not. 
    If it is not successful, it returns an error message
@description Creates a new assignment associated to the *current_user*'s *account* and to the
    ticket specified by the *ticket_id* param.
@example
    # Executing this controller's action from javascript's frontend
    let data = {
        ticket_assignment: {
            users_id: 3
        }
    };
    let ticket_id = 3;
    this.http.post(`127.0.0.1/help/tickets/${this.ticket_id}/assignments`, data);
=end
        def create
            return respond_with_not_found unless @ticket
            return respond_with_unauthorized unless @ticket.is_editable_by?(current_user)

            assignment = Ticket::Assignment.new(ticket_assignment_params)
            assignment.ticket = @ticket

            if assignment.save
                Ticket.log_activity_create_assignment(current_user, @ticket, assignment)
                TicketMailer.with({user: assignment.user, ticket: @ticket}).assignment.deliver_later

                respond_with_successful(assignment)
            else
                respond_with_error(assignment.errors.full_messages.to_sentence)
            end
        end

=begin
@return [Json] Json that contains wheter the ticket assignment was successfully deleted or not. 
    If it it not successful, it returns an error message
@description Deletes an existing *ticket* *assignment* associated to the *current_user*'s *account*.
@example
    # Executing this controller's action from javascript's frontend
    let ticket_id = 4;
    let assignment_id = 5;
    this.http.delete(`127.0.0.1/help/tickets/${ticket_id}/assignments/${assignment_id}`);
=end
        def destroy
            return respond_with_not_found unless @ticket
            return respond_with_unauthorized unless @ticket.is_editable_by?(current_user)

            assignment = @ticket.assignments.find_by(id: params[:id])
            return respond_with_not_found unless assignment

            if assignment.destroy
                respond_with_successful
                Ticket.log_activity_destroy_assignment(current_user, @ticket, assignment)
            else
                respond_with_error(assignment.errors.full_messages.to_sentence)
            end
        end

        private
        
=begin
@return [void]
@description Sets the variable @ticket. The variable contains the *ticket*
    to be handled by the controller action that called this method
@example
    #suppose params[:ticket_id] = 1
    puts @ticket # will display nil
    set_ticket
    puts @ticket # will display an instance of CloudHouse:Ticket
=end
        def set_ticket
            @ticket = Ticket.find_by(
                id: params[:ticket_id],
                cloud_help_accounts_id: current_user.account.id
            )
        end

=begin
@return [Parameters] Allowed parameters for the ticket
@description Sanitizes the parameters received from an HTTP call to only allow the specified ones.
    Allowed params are :users_id
@example
    # supose params contains {
    #    "ticket_assignment": {
    #        "id": 5,
    #        "users_id": 6
    #    }
    #}
    filtered_params = ticket_assignment_params
    puts filtered_params
    # will remove all extra fields and only print {
    #    "users_id": 6
    #}
=end
        def ticket_assignment_params
            params.fetch(:ticket_assignment, {}).permit(
                :users_id
            )
        end
    end
end
