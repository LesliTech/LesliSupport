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
    class TicketsController < ApplicationController
        before_action :set_ticket, only: [:update, :destroy, :images]

        def privileges
            {
                new: ["options"],
                edit: [],
                show: [
                    "CloudHelp::Workflows#transition_options",
                    "CloudHelp::Ticket::Assignments#options",
                    "CloudHelp::Ticket::Discussions#index",
                    "CloudHelp::Ticket::Files#index",
                    "CloudHelp::Ticket::Files#options",
                    "CloudHelp::Ticket::Histories#index",
                    "CloudHelp::Ticket::Activities#index"
                ],
                index: ['options'],
                destroy: []
            }
        end

=begin
@return [HTML|JSON] HTML view for listing all tickets or a Json that contains a list 
    of all tickets associated to this *account*
@description Retrieves and returns all tickets associated to a *CloudHelp::Account*. 
    The account is obtained directly from *current_user*. The HTTP request has to specify
    wheter the HTML or the JSON text should be rendered
@example
    # Executing this controller's action from javascript's frontend
    this.http.get(`127.0.0.1/help/tickets`);
=end
        def index
            respond_to do |format|
                format.html { }
                format.json do
                    respond_with_pagination(Ticket.index(current_user, @query))
                end
            end
        end

=begin
@return [HTML|Json] HTML view showing the requested ticket or a Json that contains the
    information of the ticket. If there is an error, an explanation message is sent
@description Retrieves and returns the requested ticket. The id of the 
    ticket is within the *params* attribute of the controller. The HTTP request has to specify
    wheter the HTML or the JSON text should be rendered
@example
    # Executing this controller's action from javascript's frontend
    let ticket_id = 1;
    this.http.get(`127.0.0.1/help/tickets/${ticket_state_id}`);
=end
        def show
            respond_to do |format|
                format.html { }
                format.json do
                    set_ticket
                    return respond_with_not_found unless @ticket 
                    respond_with_successful(@ticket.show(current_user, @query))
                end
            end
        end

=begin
@return [HTML] HTML view for creating a new ticket
@description returns an HTML view with a form so users can create a new ticket
@example
    # Executing this controller's action from javascript's frontend
    this.url.go('/help/tickets/new')
=end
        def new
        end

=begin
@return [HTML] HTML view for editing the ticket
@description returns an HTML view with a form so users edit an existing ticket
@example
    # Executing this controller's action from javascript's frontend
    let ticket_id = 3;
    this.url.go(`/help/ticket_states/${ticket_id}/edit`)
=end
        def edit
        end

=begin
@controller_action_param :detail_attributes [Hash] The fields of the detail 
    record associated to this ticket
@controller_action_param :id: [Integer] The id of the detail of
    of this ticket. Since each ticket has only one detail, this attribute is optiona
@controller_action_param :subject [String] The subject of the ticket
@controller_action_param :reference_url [String] The url from which the ticket was created
@controller_action_param :detail_attributes [Hash] The fields of the detail 
    record associated to this ticket
@controller_action_param :description [String] A description of the issue.
    Can be an HTML string
@controller_action_param :tags [String], A small list of words, separated by commas
@controller_action_param :deadline [Datetime] The date set as this ticket's deadline
@controller_action_param :cloud_help_catalog_ticket_types_id [Integer] The id of the type
    associated to this ticket
@controller_action_param :cloud_help_catalog_ticket_priorities_id [Integer] The id of the priority
    associated to this ticket
@controller_action_param :cloud_help_catalog_ticket_categories_id [Integer] The id of the category
    associated to this ticket
@controller_action_param :cloud_help_ticket_workflow_details_id [Integer] The id of the
    workflow_detail associated to this ticket. The workflow detail must be a detail of the
    workflow associated to this ticket's type and category
@return [Json] Json that contains wheter the creation of the ticket was successful or not. 
    If it is not successful, it returns an error message
@description Creates a new ticket associated to the *current_user*'s *account*. After creating
    a ticket, *current_user* is *subscribed* to all of this ticket's events, and a notification
    is sent via web about the new ticket's creation
@example
    # Executing this controller's action from javascript's frontend
    let data = {
        ticket:{
            cloud_help_catalog_ticket_types_id:2,
            cloud_help_catalog_ticket_categories_id:1,
            cloud_help_catalog_ticket_priorities_id:2,
            subject:I would like a button to print my record,
            description:`
                <div>In the <em>show screen</em>, 
                I would like you to add a button to print the record 
                I'm creating, istead of having to navigate to the 
                <strong>options menu</strong>. It would save me some time</div>
            `
        }
    }
    this.http.post('127.0.0.1/help/tickets', data);
=end
        def create
            ticket_create_response = TicketServices.create(current_user, ticket_params)
            if ticket_create_response.successful?
                respond_with_successful(ticket_create_response.payload)
            else
                respond_with_error(ticket_create_response.error.full_messages.to_sentence)
            end
        end

=begin
@controller_action_param :detail_attributes [Hash] The fields of the detail 
    record associated to this ticket
@controller_action_param :id: [Integer] The id of the detail of
    of this ticket. Since each ticket has only one detail, this attribute is optiona
@controller_action_param :subject [String] The subject of the ticket
@controller_action_param :description [String] A description of the issue.
    Can be an HTML string
@controller_action_param :reference_url [String] The url from which the ticket was created
@controller_action_param :tags [String], A small list of words, separated by commas
@controller_action_param :deadline [Datetime] The date set as this ticket's deadline
@controller_action_param :cloud_help_catalog_ticket_types_id [Integer] The id of the type
    associated to this ticket
@controller_action_param :cloud_help_catalog_ticket_priorities_id [Integer] The id of the priority
    associated to this ticket
@controller_action_param :cloud_help_catalog_ticket_categories_id [Integer] The id of the category
    associated to this ticket
@controller_action_param :cloud_help_ticket_workflow_details_id [Integer] The id of the
    workflow_detail associated to this ticket. The workflow detail must be a detail of the
    workflow associated to this ticket's type and category
@return [Json] Json that contains wheter the creation of the ticket was successful or not. 
    If it is not successful, it returns an error message
@description Updates an existing ticket associated to the *current_user*'s *account*. 
    Depending on the attributes updated, notifications are sent to the *users* that are
    subscribed. For example, if the priority changes from *Low* to *High*, a
    *ticket_escalated* notification is sent to all subscribers.
@example
    # Executing this controller's action from javascript's frontend
    let data = {
        ticket:{
            cloud_help_catalog_ticket_types_id:2,
            cloud_help_catalog_ticket_categories_id:1,
            cloud_help_catalog_ticket_priorities_id:2,
            subject:I would like a button to print my record,
            description:`
                <div>In the <em>show screen</em>, 
                I would like you to add a button to print the record 
                I'm creating, istead of having to navigate to the 
                <strong>options menu</strong>. It would save me some time</div>
            `
        }
    }
    this.http.post('127.0.0.1/help/tickets', data);
=end
        def update
            return respond_with_not_found unless @ticket
            return respond_with_unauthorized unless @ticket.is_editable_by?(current_user, bypass_status: true)

            # When the ticket is closed, the only available field for update is the status
            update_params = ticket_params
            if ["completed_successfully", "completed_unsuccessfully"].include? @ticket.status&.status_type
                update_params = completed_ticket_params
            end

            if @ticket.check_workflow_transitions(current_user, update_params)
                ticket_update_response = TicketServices.update(current_user, @ticket, update_params)

                @ticket = ticket_update_response.payload
                if ticket_update_response.successful?
                    respond_with_successful(@ticket.show(current_user, @query))
                else
                    respond_with_error(@ticket.errors.full_messages.to_sentence)
                end
            else
                respond_with_error(@ticket.errors.full_messages.to_sentence)
            end
        end

=begin
@description Retrieves a list of *ticket* *types*, *ticket* *categories* and *ticket*
    *priorities* needed to create a new ticket.
@example
    # Executing this controller's action from javascript's frontend
    this.http.get('127.0.0.1/help/tickets/options').then(response => {
        if( response.successful ){
            console.log(JSON.stringify(response.data))
            # This will print something similar to
            #{
            #    "types":[
            #        {"id":1,"name":"Issue"},
            #        {"id":2,"name":"Change Request"}
            #    ],
            #    "categories":[
            #        {
            #            "id":1,"name":"Company System",
            #            "ancestry":null,"has_children":true,
            #            "active":true,"children_active":false,
            #            "depth":0
            #        },{
            #            "id":2,"name":"Books Module",
            #            "ancestry":"1","has_children":false,
            #            "active":false,"children_active":false,
            #            "depth":1
            #        }
            #    ],
            #    "priorities":[
            #        {"id":1,"name":"Low","weight":10},
            #        {"id":2,"name":"Medium","weight":100},
            #        {"id":3,"name":"High","weight":1000}
            #    ]
            #}
        }
    });
=end
        def options
            respond_with_successful(Ticket.options(current_user, @query))
        end

        # @return [Json] Json that contains wheter the ticket was successfully deleted or not. 
        #     If it it not successful, it returns an error message
        # @description Deletes an existing *ticket* associated to the *current_user*'s *account*.
        # @example
        #     # Executing this controller's action from javascript's frontend
        #     let ticket_id = 4;
        #     this.http.delete(`127.0.0.1/help/tickets/${ticket_id}`);
        def destroy
            return respond_with_not_found unless @ticket
            return respond_with_unauthorized unless @ticket.is_editable_by?(current_user)

            ticket_destroy_response = TicketServices.destroy(current_user, @ticket)

            if ticket_destroy_response.successful?
                respond_with_successful
            else
                respond_with_error(ticket_destroy_response.payload.errors.full_messages.to_sentence)
            end
        end

        def images
            return respond_with_not_found unless @ticket

            images = @ticket.files.filter do |file|
                file_name = ""
                file_name = file.attachment_s3_identifier.downcase if file.attachment_s3_identifier
                file_name = file.attachment_identifier.downcase if file.attachment_identifier

                file_name.end_with?('png') || file_name.end_with?('jpg') || file_name.end_with?('jpeg')
            end

            images = images.map do |image|
                {
                    id: image.id,
                    name: image.name,
                    src: "/help/tickets/#{@ticket.id}/files/#{image.id}",
                    href: "/help/tickets/#{@ticket.id}/files/#{image.id}?view=true"
                }
            end

            respond_with_successful(images)
        end

        private

=begin
@return [void]
@description Sets the variable @ticket. The variable contains the *ticket*
    to be handled by the controller action that called this method
@example
    #suppose params[:id] = 1
    puts @ticket # will display nil
    set_ticket_state
    puts @ticket # will display an instance of CloudHelp:Ticket
=end
        def set_ticket
            ticket_id = params[:id] unless params[:id].blank?
            ticket_id = params[:ticket_id] unless params[:ticket_id].blank?
            @ticket = current_user.account.help.tickets.find_by(id: ticket_id)
        end
        
=begin
@return [Parameters] Allowed parameters for the ticket
@description Sanitizes the parameters received from an HTTP call to only allow the
    specified ones. Allowed params are (:id, :subject, :description, :tags, :deadline, 
    :cloud_help_catalog_ticket_types_id, :cloud_help_catalog_ticket_priorities_id, 
    :cloud_help_catalog_ticket_categories_id, :cloud_help_ticket_worklfow_details_id)
@example
    # supose params contains {
    #    "ticket": {
    #        "id": 5,
    #        "name": "My ticket",
    #        "tags": "Important, Company"
    #    }
    #}
    filtered_params = ticket_params
    puts filtered_params
    # will remove the id and only print {
    #    "tags": "Important, Company"
    #}
=end
        def ticket_params
            params.require(:ticket).permit(
                :cloud_help_catalog_ticket_types_id,
                :cloud_help_catalog_ticket_priorities_id,
                :cloud_help_catalog_ticket_categories_id,
                :cloud_help_catalog_ticket_workspaces_id,
                :cloud_help_workflow_statuses_id,
                :subject,
                :description,
                :reference_url,
                :tags,
                :hours_worked,
                :deadline
            )
        end

=begin
@return [Parameters] Allowed parameters for a ticket that has already been completed
@description Sanitizes the parameters received from an HTTP call to only allow the
    specified ones. Allowed params are (cloud_help_ticket_worklfow_details_id)
@example
    # supose params contains {
    #    "ticket": {
    #        "id": 5,
    #        "name": "My ticket",
    #        "cloud_help_workflow_statuses_id": 12
    #    }
    #}
    filtered_params = completed_ticket_params
    puts filtered_params
    # will remove the id and only print {
    #        "cloud_help_workflow_statuses_id": 12
    #}
=end
        def completed_ticket_params
            params.require(:ticket).permit(
                :cloud_help_workflow_statuses_id
            )
        end

    end
end
