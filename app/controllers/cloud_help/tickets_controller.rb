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
@description Controller for tickets

=end
    class TicketsController < ApplicationController

        before_action :set_ticket, only: [:update]

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
                    tickets = Ticket.list(current_user.account.help)
                    responseWithSuccessful(tickets) 
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
                    responseWithSuccessful(@ticket.detailed_info)
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
            ticket.set_workflow

            if ticket.save
                responseWithSuccessful(ticket)
                Ticket::Subscriber.add_subscriber(ticket, current_user)
                Ticket::Subscriber.notify_subscribers(
                    ticket,
                    I18n.t('cloud_help.controllers.tickets.notifications.created', ticket_id: ticket.id),
                    :ticket_created
                )
            else
                responseWithError(@ticket.errors.full_messages.to_sentence)
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
            if @ticket.update(ticket_params)
                responseWithSuccessful(@ticket.detailed_info)
            else
                responseWithError(@ticket.errors.full_messages.to_sentence)
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
        def ticket_options
            help_account = current_user.account.help
            responseWithSuccessful({
                types: Catalog::TicketType.where(account: help_account).select(:id, :name),
                categories: Catalog::TicketCategory.tree(current_user.account),
                priorities: Catalog::TicketPriority.where(account: help_account).select(:id, :name, :weight)
            })
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
