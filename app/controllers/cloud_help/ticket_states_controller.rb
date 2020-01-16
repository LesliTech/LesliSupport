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
@description Controller for ticket states

=end
    class TicketStatesController < ApplicationController
        before_action :set_ticket_state, only: [:update, :destroy]

=begin
@return [HTML|JSON] HTML view for listing all ticket states or a Json that contains a list 
    of all ticket states associated to this *account*
@description Retrieves and returns all ticket states associated to a *CloudHelp::Account*. 
    The account is obtained directly from *current_user*. The HTTP request has to specify
    wheter the HTML or the JSON text should be rendered
@example
    # Executing this controller's action from javascript's frontend
    this.http.get(`127.0.0.1/help/ticket_states`);
=end
        def index
            respond_to do |format|
                format.html {}
                format.json do
                    ticket_states = current_user.account.help.ticket_states.select(
                        :id,
                        :name,
                        :initial,
                        :final,
                        :created_at,
                        :updated_at
                    ).order(name: :asc)
                    responseWithSuccessful(ticket_states) 
                end
            end
        end

=begin
@return [HTML|Json] HTML view showing the requested ticket state or a Json that contains the
    information of the ticket state. If there is an error, an explanation message is sent
@description Retrieves and returns the requested ticket state. The id of the 
    state is within the *params* attribute of the controller. The HTTP request has to specify
    wheter the HTML or the JSON text should be rendered
@example
    # Executing this controller's action from javascript's frontend
    let ticket_state_id = 1;
    this.http.get(`127.0.0.1/help/ticket_states/${ticket_state_id}`);
=end
        def show
            respond_to do |format|
                format.html {}
                format.json do
                    set_ticket_state
                    return responseWithNotFound unless @ticket_state

                    responseWithSuccessful(@ticket_state)
                end
            end
        end

=begin
@return [HTML] HTML view for creating a new ticket state
@description returns an HTML view with a form so users can create a new ticket state
@example
    # Executing this controller's action from javascript's frontend
    this.url.go('/help/ticket_states/new')
=end
        def new
        end

=begin
@return [HTML] HTML view for editing the ticket state
@description returns an HTML view with a form so users edit an existing ticket state
@example
    # Executing this controller's action from javascript's frontend
    let ticket_state_id = 3;
    this.url.go(`/help/ticket_states/${ticket_states_id}/edit`)
=end
        def edit
        end

=begin
@controller_action_param :name [String] The name of the new state
@return [Json] Json that contains wheter the creation of the ticket state was successful or not. 
    If it is not successful, it returns an error message
@description Creates a new ticket state associated to the *current_user*'s *account*
@example
    # Executing this controller's action from javascript's frontend
    let data = {
        ticket_state: {
            name: "In Progress"
        }
    };
    this.http.post('127.0.0.1/help/ticket_states', data);
=end
        def create
            ticket_state = TicketState.new(ticket_state_params)
            ticket_state.cloud_help_accounts_id = current_user.account.id

            if ticket_state.save
                responseWithSuccessful(ticket_state)
            else
                responseWithError(ticket_state.errors.full_messages.to_sentence)
            end
        end

=begin
@controller_action_param :name [String] The name of the state
@return [Json] Json that contains wheter the ticket state was successfully updated or not. 
    If it it not successful, it returns an error message
@description Updates an existing ticket state associated to the *current_user*'s *account*.
@example
    # Executing this controller's action from javascript's frontend
    let ticket_state_id = 4;
    let data = {
        ticket_state: {
            name: "Verifying Quality"
        }
    };
    this.http.put(`127.0.0.1/help/ticket_states/${ticket_state_id}`, data);
=end
        def update
            return responseWithNotFound unless @ticket_state

            if @ticket_state.update(ticket_state_params)
                responseWithSuccessful(@ticket_state)
            else
                responseWithError(@ticket_state.errors.full_messages.to_sentence)
            end
        end

=begin
@return [Json] Json that contains wheter the ticket state was successfully deleted or not. 
    If it it not successful, it returns an error message
@description Deletes an existing *ticket* *state* associated to the *current_user*'s *account*.
    If there is an existing *ticket* associated to the *ticket* *state*, it cannot be deleted
@example
    # Executing this controller's action from javascript's frontend
    let ticket_state_id = 4;
    this.http.delete(`127.0.0.1/help/ticket_states/${ticket_state_id}`);
=end
        def destroy
            return responseWithNotFound unless @ticket_state
            
            if @ticket_state.destroy
                responseWithSuccessful
            else
                responseWithError(@ticket_state.errors.full_messages.to_sentence)
            end
        end

        private

=begin
@return [void]
@description Sets the variable @ticket_state. The variable contains the *ticket* *state* 
    to be handled by the controller action that called this method
@example
    #suppose params[:id] = 1
    puts @ticket_state # will display nil
    set_ticket_state
    puts @ticket_state # will display an instance of CloudHelp:TicketState
=end
        def set_ticket_state
            @ticket_state = TicketState.find_by(
                id: params[:id],
                cloud_help_accounts_id: current_user.account.id
            )
        end

=begin
@return [Parameters] Allowed parameters for the ticket state
@description Sanitizes the parameters received from an HTTP call to only allow the specified ones.
    Allowed params are _:name_
@example
    # supose params contains {
    #    "ticket_state": {
    #        "id": 5,
    #        "name": "Reviewing Changes"
    #    }
    #}
    filtered_params = ticket_state_params
    puts filtered_params
    # will remove the id and only print {
    #    "name": "Reviewing Changes"
    #}
=end
        def ticket_state_params
            params.fetch(:ticket_state, {}).permit(:name)
        end
    end
end
