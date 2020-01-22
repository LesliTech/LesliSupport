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
@description Controller for ticket categories

=end
  class TicketCategoriesController < ApplicationController
    before_action :set_ticket_category, only: [:update, :destroy, :api_tree]

=begin
@return [HTML|JSON] HTML view for listing all ticket categories or a Json that contains a list of all ticket categories 
    associated to this *account*
@description Retrieves and returns all ticket categories associated to a *CloudHelp::Account*. The account
    is obtained directly from *current_user*. The HTTP request has to specify
    wheter the HTML or the JSON text should be rendered
@example
    # Executing this controller's action from javascript's frontend
    this.http.get(`127.0.0.1/help/ticket_categories`);
=end
    def index
        respond_to do |format|
            format.html {}
            format.json do 
                ticket_categories = TicketCategory.tree(current_user.account)
                responseWithSuccessful(ticket_categories)
            end
        end
    end

=begin
@return [HTML|Json] HTML view showing the requested ticket category or a Json that contains the
    information of the ticket category. If there is an error, an explanation message is sent
@description Retrieves and returns the requested ticket category. The id of the 
    category is within the *params* attribute of the controller. The HTTP request has to specify
    wheter the HTML or the JSON text should be rendered
@example
    # Executing this controller's action from javascript's frontend
    let ticket_category_id = 1;
    this.http.get(`127.0.0.1/help/ticket_categories/${ticket_category_id}`);
=end
    def show
        respond_to do |format|
            format.html {}
            format.json do
                set_ticket_category
                return responseWithNotFound unless @ticket_category

                responseWithSuccessful(@ticket_category)
            end
        end
    end

=begin
@return [HTML] HTML view for creating a new ticket category
@description returns an HTML view with a form so users can create a new ticket category
@example
    # Executing this controller's action from javascript's frontend
    this.url.go('/help/ticket_categories/new')
=end
    def new
    end

=begin
@return [HTML] HTML view for editing the ticket category
@description returns an HTML view with a form so users edit an existing ticket category
@example
    # Executing this controller's action from javascript's frontend
    let ticket_category_id = 3;
    this.url.go(`/help/ticket_categories/${ticket_category_id}/edit`)
=end
    def edit
    end

=begin
@controller_action_param :name [String] The name of the new category
@controller_action_param :parent_id [Integer] The id of the parent category
@return [Json] Json that contains wheter the creation of the ticket category was successful or not. 
    If it is not successful, it returns an error message
@description Creates a new ticket category associated to the *current_user*'s *account*. If the category is
    successfully created, a new *ticket* *workflow* is created for each existing *ticket* *category* and
    this new *ticket category*
@example
    # Executing this controller's action from javascript's frontend
    let data = {
        ticket_category: {
            name: "Sales"
        }
    };
    this.http.post('127.0.0.1/help/ticket_categorys', data);
=end
    def create
        ticket_category = TicketCategory.new(ticket_category_params)
        ticket_category.cloud_help_accounts_id = current_user.account.id
        
        if ticket_category.save
            responseWithSuccessful(ticket_category)
        else
            responseWithError(ticket_category.errors.full_messages.to_sentence)
        end
    end

=begin
@controller_action_param :name [String] The name of the category
@controller_action_param :parent_id [Integer] The id of the parent category
@return [Json] Json that contains wheter the ticket category was successfully updated or not. 
    If it it not successful, it returns an error message
@description Updates an existing ticket category associated to the *current_user*'s *account*.
@example
    # Executing this controller's action from javascript's frontend
    let ticket_category_id = 4;
    let data = {
        ticket_category: {
            name: "Billing",
            parent_id: 4
        }
    };
    this.http.put(`127.0.0.1/help/ticket_categories/${ticket_category_id}`, data);
=end
    def update
        return responseWithNotFound unless @ticket_category

        if @ticket_category.update(ticket_category_params)
            responseWithSuccessful(@ticket_category)
        else
            responseWithError(@ticket_category.errors.full_messages.to_sentence)
        end
    end

=begin
@return [Json] Json that contains wheter the ticket category was successfully deleted or not. 
    If it it not successful, it returns an error message
@description Deletes an existing *ticket* *category* associated to the *current_user*'s *account*.
    Since each ticket category has a *ticket* *workflow* associated, the workflow is also deleted. However, if there
    is an existing *ticket* associated to the *ticket* *category*, it cannot be deleted
@example
    # Executing this controller's action from javascript's frontend
    let ticket_category_id = 4;
    this.http.delete(`127.0.0.1/help/ticket_categories/${ticket_category_id}`);
=end
    def destroy
        return responseWithNotFound unless @ticket_category
        
        if @ticket_category.destroy
            responseWithSuccessful
        else
            responseWithError(@ticket_category.errors.full_messages.to_sentence)
        end
    end

=begin
@return [Json] Json that contains the information of the ticket category and all its parent
    categories. If there is an error, an explanation message is sent
@description Retrieves and returns the requested ticket category, along with its parent categories.
    The id of the category is within the *params* attribute of the controller.
@example
    # Executing this controller's action from javascript's frontend
    let ticket_category_id = 1;
    this.http.get(`127.0.0.1/help/api/ticket_categories/${ticket_category_id}/tree`);
@deprecated This method will be removed in the next update and it's functionality will be implemented
    in the *show* method when requesting a Json response.
=end
    def api_tree
        responseWithSuccessful(@ticket_category.tree)
    end

    private
=begin
@return [void]
@description Sets the variable @ticket_category. The variable contains the *ticket* *category* 
    to be handled by the controller action that called this method
@example
    #suppose params[:id] = 1
    puts @ticket_category # will display nil
    set_ticket_category
    puts @ticket_category # will display an instance of CloudHelp:TicketCategory
=end
        def set_ticket_category
            @ticket_category = TicketCategory.find_by(
                id: params[:id],
                cloud_help_accounts_id: current_user.account.id
            )
        end

=begin
@return [Parameters] Allowed parameters for the ticket category
@description Sanitizes the parameters received from an HTTP call to only allow the specified ones.
    Allowed params are _:name_, _:parent_id_
@example
    # supose params contains {
    #    "ticket_category": {
    #        "name": "Sales",
    #        "parent_id": 44,
    #        "parent_name": "Company System"
    #    }
    #}
    filtered_params = ticket_category_params
    puts filtered_params
    # will remove the _parent_name_ field and only print {
    #    "ticket_category": {
    #        "name": "Sales",
    #        "parent_id": 44,
    #    }
    #}
=end
        def ticket_category_params
            params.fetch(:ticket_category, {}).permit(:name, :parent_id)
        end
  end
end
