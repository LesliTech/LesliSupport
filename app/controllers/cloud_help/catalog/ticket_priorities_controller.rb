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
    class Catalog::TicketPrioritiesController < ApplicationLesliController
        before_action :set_ticket_priority, only: [:update, :destroy]

=begin
@return [HTML|JSON] HTML view for listing all ticket priorities or a Json that contains a list 
    of all ticket priorities associated to this *account*
@description Retrieves and returns all ticket priorities associated to a *CloudHelp::Account*. 
    The account is obtained directly from *current_user*. The HTTP request has to specify
    wheter the HTML or the JSON text should be rendered
@example
    # Executing this controller's action from javascript's frontend
    this.http.get(`127.0.0.1/help/ticket_priorities`);
=end
        def index
            respond_to do |format|
                format.html {}
                format.json do
                    responseWithSuccessful(Catalog::TicketPriority.index(current_user, @query))
                end
            end
        end

=begin
@return [HTML|Json] HTML view showing the requested ticket priority or a Json that contains the
    information of the ticket priority. If there is an error, an explanation message is sent
@description Retrieves and returns the requested ticket priority. The id of the 
    priority is within the *params* attribute of the controller. The HTTP request has to specify
    wheter the HTML or the JSON text should be rendered
@example
    # Executing this controller's action from javascript's frontend
    let ticket_priority_id = 1;
    this.http.get(`127.0.0.1/help/ticket_priorities/${ticket_priority_id}`);
=end
        def show
            respond_to do |format|
                format.html {}
                format.json do
                    set_ticket_priority
                    return responseWithNotFound unless @ticket_priority

                    responseWithSuccessful(@ticket_priority.show)
                end
            end
        end

=begin
@return [HTML] HTML view for creating a new ticket priority
@description returns an HTML view with a form so users can create a new ticket priority
@example
    # Executing this controller's action from javascript's frontend
    this.url.go('/help/ticket_priorities/new')
=end
        def new
        end

=begin
@return [HTML] HTML view for editing the ticket priority
@description returns an HTML view with a form so users edit an existing ticket priority
@example
    # Executing this controller's action from javascript's frontend
    let ticket_priority_id = 3;
    this.url.go(`/help/ticket_priorities/${ticket_priority_id}/edit`)
=end
        def edit
        end

=begin
@controller_action_param :name [String] The name of the new priority
@controller_action_param :weight [Integer] The weight of the new priority
    The higher the number means it is more important.
@return [Json] Json that contains wheter the creation of the ticket priority was successful or not. 
    If it is not successful, it returns an error message
@description Creates a new ticket priority associated to the *current_user*'s *account*
@example
    # Executing this controller's action from javascript's frontend
    let data = {
        ticket_priority: {
            name: "Important",
            weight: 100
        }
    };
    this.http.post('127.0.0.1/help/ticket_priorities', data);
=end
        def create
            ticket_priority = Catalog::TicketPriority.new(ticket_priority_params)
            ticket_priority.cloud_help_accounts_id = current_user.account.id

            if ticket_priority.save
                responseWithSuccessful(ticket_priority)
            else
                responseWithError(ticket_priority.errors.full_messages.to_sentence)
            end
        end

=begin
@controller_action_param :name [String] The name of the priority
@controller_action_param :weight [Integer] The weight of the new priority
@return [Json] Json that contains wheter the ticket priority was successfully updated or not. 
    If it it not successful, it returns an error message
@description Updates an existing ticket priority associated to the *current_user*'s *account*.
@example
    # Executing this controller's action from javascript's frontend
    let ticket_priority_id = 4;
    let data = {
        ticket_priority: {
            name: "Very Important",
            weight: 101
        }
    };
    this.http.put(`127.0.0.1/help/ticket_priorities/${ticket_priority_id}`, data);
=end
        def update
            return responseWithNotFound unless @ticket_priority

            if @ticket_priority.update(ticket_priority_params)
                responseWithSuccessful(@ticket_priority)
            else
                responseWithError(@ticket_priority.errors.full_messages.to_sentence)
            end
        end

=begin
@return [Json] Json that contains wheter the ticket priority was successfully deleted or not. 
    If it it not successful, it returns an error message
@description Deletes an existing *ticket* *priority* associated to the *current_user*'s *account*.
    If there is an existing *ticket* associated to the *ticket* *priority*, it cannot be deleted
@example
    # Executing this controller's action from javascript's frontend
    let ticket_priority_id = 4;
    this.http.delete(`127.0.0.1/help/ticket_priorities/${ticket_priority_id}`);
=end
        def destroy
            return responseWithNotFound unless @ticket_priority

            if @ticket_priority.destroy
                responseWithSuccessful
            else
                responseWithError(@ticket_priority.errors.full_messages.to_sentence)
            end
        end

        private

=begin
@return [void]
@description Sets the variable @ticket_priority. The variable contains the *ticket* *priority* 
    to be handled by the controller action that called this method
@example
    #suppose params[:id] = 1
    puts @ticket_priority # will display nil
    set_ticket_priority
    puts @ticket_priority # will display an instance of CloudHelp:Catalog::TicketPriority
=end
        def set_ticket_priority
            @ticket_priority = Catalog::TicketPriority.find_by(
                id: params[:id],
                cloud_help_accounts_id: current_user.account.id
            )
        end

=begin
@return [Parameters] Allowed parameters for the ticket priority
@description Sanitizes the parameters received from an HTTP call to only allow the specified ones.
    Allowed params are _:name_, _:weight_
@example
    # supose params contains {
    #    "ticket_priority": {
    #        "id": 5,
    #        "name": "Low",
    #        "weight": 400
    #    }
    #}
    filtered_params = ticket_priority_params
    puts filtered_params
    # will remove the id and only print {
    #    "ticket_priority": {
    #        "name": "Low",
    #        "weight": 400
    #    }
    #}
=end
        def ticket_priority_params
            params.fetch(:ticket_priority, {}).permit(:name, :weight)
        end
    end
end
