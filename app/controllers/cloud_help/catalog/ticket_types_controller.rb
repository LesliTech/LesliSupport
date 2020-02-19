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
@description Controller for ticket types

=end
    class Catalog::TicketTypesController < ApplicationController
        before_action :set_ticket_type, only: [:update, :destroy]

=begin
@return [HTML|JSON] HTML view for listing all ticket types or a Json that contains a list of all ticket types 
    associated to this *account*
@description Retrieves and returns all ticket types associated to a *CloudHelp::Account*. The account
    is obtained directly from *current_user*. The HTTP request has to specify
    wheter the HTML or the JSON text should be rendered
@example
    # Executing this controller's action from javascript's frontend
    this.http.get(`127.0.0.1/help/ticket_types`);
=end
        def index
            respond_to do |format|
                format.html {}
                format.json do
                    ticket_types = current_user.account.help.ticket_types.select(
                        :id,
                        :name,
                        :created_at,
                        :updated_at
                    )
                    responseWithSuccessful(ticket_types) 
                end
            end
        end

=begin
@return [HTML|Json] HTML view showing the requested ticket type or a Json that contains the
    information of the ticket type. If there is an error, an explanation message is sent
@description Retrieves and returns the requested ticket type. The id of the 
    type is within the *params* attribute of the controller. The HTTP request has to specify
    wheter the HTML or the JSON text should be rendered
@example
    # Executing this controller's action from javascript's frontend
    let ticket_type_id = 1;
    this.http.get(`127.0.0.1/help/ticket_types/${ticket_type_id}`);
=end
        def show
            respond_to do |format|
                format.html {}
                format.json do
                    set_ticket_type
                    return responseWithNotFound unless @ticket_type

                    responseWithSuccessful(@ticket_type)
                end
            end
        end

=begin
@return [HTML] HTML view for creating a new ticket type
@description returns an HTML view with a form so users can create a new ticket type
@example
    # Executing this controller's action from javascript's frontend
    this.url.go('/help/ticket_types/new')
=end
        def new
        end

=begin
@return [HTML] HTML view for editing the ticket type
@description returns an HTML view with a form so users edit an existing ticket type
@example
    # Executing this controller's action from javascript's frontend
    let ticket_type_id = 3;
    this.url.go(`/help/ticket_types/${ticket_type_id}/edit`)
=end
        def edit
        end

=begin
@controller_action_param :name [String] The name of the new type
@return [Json] Json that contains wheter the creation of the ticket type was successful or not. 
    If it is not successful, it returns an error message
@description Creates a new ticket type associated to the *current_user*'s *account*. If the type is
    successfully created, a new *ticket* *workflow* is created for each existing *ticket* *category* and
    this new *ticket type*
@example
    # Executing this controller's action from javascript's frontend
    let data = {
        ticket_type: {
            name: "Change Request"
        }
    };
    this.http.post('127.0.0.1/help/ticket_types', data);
=end
        def create
            ticket_type = Catalog::TicketType.new(ticket_type_params)
            ticket_type.cloud_help_accounts_id = current_user.account.id

            if ticket_type.save
                responseWithSuccessful(ticket_type)
            else
                responseWithError(ticket_type.errors.full_messages.to_sentence)
            end
        end

=begin
@controller_action_param :name [String] The name of the type
@return [Json] Json that contains wheter the ticket type was successfully updated or not. 
    If it it not successful, it returns an error message
@description Updates an existing ticket type associated to the *current_user*'s *account*.
@example
    # Executing this controller's action from javascript's frontend
    let ticket_type_id = 4;
    let data = {
        ticket_type: {
            name: "Issue"
        }
    };
    this.http.patch(`127.0.0.1/help/ticket_types/${ticket_type_id}`, data);
=end
        def update
            return responseWithNotFound unless @ticket_type

            if @ticket_type.update(ticket_type_params)
                responseWithSuccessful(@ticket_type)
            else
                responseWithError(@ticket_type.errors.full_messages.to_sentence)
            end
        end

=begin
@return [Json] Json that contains wheter the ticket type was successfully deleted or not. 
    If it it not successful, it returns an error message
@description Deletes an existing *ticket* *type* associated to the *current_user*'s *account*.
    Since each ticket type has a *ticket* *workflow* associated, the workflow is also deleted. However, if there
    is an existing *ticket* associated to the *ticket* *type*, it cannot be deleted
@example
    # Executing this controller's action from javascript's frontend
    let ticket_type_id = 4;
    this.http.delete(`127.0.0.1/help/ticket_types/${ticket_type_id}`);
=end
        def destroy
            return responseWithNotFound unless @ticket_type

            if @ticket_type.destroy
                responseWithSuccessful
            else
                responseWithError(@ticket_type.errors.full_messages.to_sentence)
            end
        end

        private
        
=begin
@return [void]
@description Sets the variable @ticket_type. The variable contains the *ticket* *type* 
    to be handled by the controller action that called this method
@example
    #suppose params[:id] = 1
    puts @ticket_type # will display nil
    set_ticket_type
    puts @ticket_type # will display an instance of CloudHelp:Catalog::TicketType
=end
        def set_ticket_type
            @ticket_type = Catalog::TicketType.find_by(
                id: params[:id],
                cloud_help_accounts_id: current_user.account.id
            )
        end

=begin
@return [Parameters] Allowed parameters for the ticket type
@description Sanitizes the parameters received from an HTTP call to only allow the specified ones.
    Allowed params are _:name_
@example
    # supose params contains {
    #    "ticket_type": {
    #        "id": 5,
    #        "name": "Suggestion",
    #        "file": FILE_CONTENT,
    #        "word": false
    #    }
    #}
    filtered_params = ticket_type_params
    puts filtered_params
    # will remove _id_ , _file_ and _word_ fields and only print {
    #    "ticket_type": {
    #        "name": "Suggestion"
    #    }
    #}
=end
        def ticket_type_params
            params.fetch(:ticket_type, {}).permit(:name)
        end
    end
end
