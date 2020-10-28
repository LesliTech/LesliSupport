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
    class TicketsController < ApplicationLesliController

        before_action :set_ticket, only: [:update, :destroy]

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
                    tickets = Ticket.index(current_user, @query)
                    respond_with_successful(tickets) 
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
                    respond_with_successful(@ticket.show)
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
@controller_action_param :detail_attributes.id: [Integer] The id of the detail of
    of this ticket. Since each ticket has only one detail, this attribute is optiona
@controller_action_param :detail_attributes.subject [String] The subject of the ticket
@controller_action_param :detail_attributes.description [String] A description of the issue.
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
            detail_attributes:{
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
    }
    this.http.post('127.0.0.1/help/tickets', data);
=end
        def create
            ticket = Ticket.new(ticket_params)
            ticket.source = Catalog::TicketSource.cloud_help_source(current_user.account.help)
            ticket.account = current_user.account.help
            ticket.user_creator = current_user
            ticket.set_workflow

            if ticket.save
                Ticket::Subscriber.add_subscriber(ticket, current_user)
                Ticket::Subscriber.notify_subscribers(
                    ticket,
                    I18n.t('cloud_help.controllers.tickets.notifications.created', ticket_id: ticket.id),
                    :ticket_created
                )
                Ticket.log_activity_create(current_user, ticket)

                respond_with_successful(ticket)
            else
                responseWithError(ticket.errors.full_messages.to_sentence)
            end
        end

=begin
@controller_action_param :detail_attributes [Hash] The fields of the detail 
    record associated to this ticket
@controller_action_param :detail_attributes.id: [Integer] The id of the detail of
    of this ticket. Since each ticket has only one detail, this attribute is optiona
@controller_action_param :detail_attributes.subject [String] The subject of the ticket
@controller_action_param :detail_attributes.description [String] A description of the issue.
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
@description Updates an existing ticket associated to the *current_user*'s *account*. 
    Depending on the attributes updated, notifications are sent to the *users* that are
    subscribed. For example, if the priority changes from *Low* to *High*, a
    *ticket_escalated* notification is sent to all subscribers.
@example
    # Executing this controller's action from javascript's frontend
    let data = {
        ticket:{
            detail_attributes:{
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
    }
    this.http.post('127.0.0.1/help/tickets', data);
=end
        def update
            return respond_with_not_found unless @ticket

            old_attributes = @ticket.attributes.merge({
                "detail_attributes" => @ticket.detail.attributes
            })

            if @ticket.update(ticket_params)
                respond_with_successful(@ticket.show)

                new_attributes = @ticket.attributes.merge({
                    "detail_attributes" => @ticket.detail.attributes
                })
                Ticket.log_activity_update(current_user, @ticket, old_attributes, new_attributes)
                Workflow::Action.execute_actions(current_user, @ticket, old_attributes, new_attributes)
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
        #     this.http.delete(`127.0.0.1/house/tickets/${ticket_id}`);
        def destroy
            return respond_with_not_found unless @ticket

            if @ticket.destroy
                respond_with_successful

                Ticket.log_activity_destroy(current_user, @ticket)
            else
                respond_with_error(@ticket.errors.full_messages.to_sentence)
            end
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
            @ticket = current_user.account.help.tickets.find(ticket_id)
        end
        
=begin
@return [Parameters] Allowed parameters for the ticket
@description Sanitizes the parameters received from an HTTP call to only allow the
    specified ones. Allowed params are :detail_attributes.
    :detail_attributes must be a Hash containing the next attributes: 
    (:id, :subject, :description, :tags, :deadline, :cloud_help_catalog_ticket_types_id, 
    :cloud_help_catalog_ticket_priorities_id, :cloud_help_catalog_ticket_categories_id, 
    :cloud_help_ticket_worklfow_details_id)
@example
    # supose params contains {
    #    "ticket": {
    #        "id": 5,
    #       "detail_attributes":{
    #            name: "My ticket",
    #            tags: "Important, Company"
    #        }
    #    }
    #}
    filtered_params = ticket_state_params
    puts filtered_params
    # will remove the id and only print {
    #   "detail_attributes":{
    #        tags: "Important, Company"
    #    }
    #}
=end
        def ticket_params
            params.require(:ticket).permit(
                :cloud_help_catalog_ticket_types_id,
                :cloud_help_catalog_ticket_priorities_id,
                :cloud_help_catalog_ticket_categories_id,
                :cloud_help_workflow_statuses_id,
                detail_attributes: [
                    :subject,
                    :description,
                    :tags,
                    :deadline
                ]
            )
        end

    end
end
