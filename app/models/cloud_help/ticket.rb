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
@description Model for ticket. Each has it's own *detail* containing it's information.
    Tickets are the core *object* of the *CloudHelp* module
=end
    class Ticket  < CloudObject::Base
        include ActiveModel::Dirty

        belongs_to :account,    class_name: "CloudHelp::Account",                   foreign_key: "cloud_help_accounts_id"
        belongs_to :type,       class_name: "CloudHelp::Catalog::TicketType",       foreign_key: "cloud_help_catalog_ticket_types_id"
        belongs_to :category,   class_name: "CloudHelp::Catalog::TicketCategory",   foreign_key: "cloud_help_catalog_ticket_categories_id"
        belongs_to :priority,   class_name: "CloudHelp::Catalog::TicketPriority",   foreign_key: "cloud_help_catalog_ticket_priorities_id"
        belongs_to :source,     class_name: "CloudHelp::Catalog::TicketSource",     foreign_key: "cloud_help_catalog_ticket_sources_id"
        belongs_to :status,     class_name: "CloudHelp::Workflow::Status",          foreign_key: "cloud_help_workflow_statuses_id"

        has_many :discussions,  foreign_key: "cloud_help_tickets_id"
        has_many :actions,      foreign_key: "cloud_help_tickets_id"
        has_many :files,        foreign_key: "cloud_help_tickets_id"
        has_many :subscribers,  foreign_key: "cloud_help_tickets_id"
        has_many :timelines,    foreign_key: "cloud_help_tickets_id"


        has_one :detail, inverse_of: :ticket, autosave: true, foreign_key: "cloud_help_tickets_id"
        has_one :assignment, foreign_key: "cloud_help_tickets_id"  

        accepts_nested_attributes_for :detail, update_only: true

        after_update :after_update_actions

=begin
@return [Boolean] Whether this ticket was successfully saved or not. If it was not saved,
    an error is added to the *ticket*'s *errors* attribute
@description saves a ticket based on the params allowed by *CloudHelp::TicketsController*. 
    If the ticket is new, creates an entry in the timeline. Also, depending on which 
    attributes where updated, notifications are sent and entries are added to the timeline
@example
    ticket_params = {
        detail_attributes: {
            cloud_help_catalog_ticket_priorities_id: 1,
            cloud_help_catalog_ticket_categories_id: 1,
            cloud_help_catalog_ticket_types_id: 1
        }
    }
    ticket = CloudHelp::Ticket.new(ticket_params)
    if ticket.save
        responseWithSuccessful
    else
        responseWithError(ticket.errors.full_messages.to_sentence)
    end
=end
        def save
            if new_record?
                if super
                    timelines.create(
                        action: Ticket::Timeline.actions[:created],
                        description: I18n.t( 'activerecord.models.cloud_help/ticket/timeline.actions.created', id: id )
                    )
                    return true
                else
                    return false
                end
            end
            super
        end

=begin
@return [Hash] Detailed information about the ticket. Including, *priority*,
    *full* *category* *path*, *type*, *creation* *user*, *assignation* *type*
    and *workflow* *state*
@description Creates a query that selects all ticket information from several tables
    and returns it in a hash
@example
    ticket = CloudHelp::Ticket.find(43)
    puts ticket.detailed_info
    # will print something like: {
    #    id:6,
    #    created_at:"2020-01-12T17:31:25.005Z",
    #    detail_attributes:{
    #        email:"admin@lesli.cloud",
    #        subject:"subject",
    #        description:"description",
    #        tags:"tags",
    #        priority:"Medium",
    #        type:"Change Request",
    #        state:"created",
    #        cloud_help_catalog_ticket_priorities_id:2,
    #        cloud_help_catalog_ticket_types_id:2,
    #        cloud_help_ticket_workflows_id:4,
    #        cloud_help_catalog_ticket_categories_id:1,
    #        cloud_help_ticket_states_id:1,
    #        deadline:null,
    #        priority_weight:100,
    #        category:"Company System"
    #    },
    #    assignment_attributes:{
    #        assignation_type:"none"
    #    }
    #}
=end
        def detailed_info
            data = Ticket.joins(
                "inner join cloud_help_catalog_ticket_priorities CHCTP on cloud_help_tickets.cloud_help_catalog_ticket_priorities_id = CHCTP.id"
            ).joins(
                "inner join cloud_help_catalog_ticket_types CHCTT on cloud_help_tickets.cloud_help_catalog_ticket_types_id = CHCTT.id"
            ).joins(
                "inner join cloud_help_catalog_ticket_categories CHCTC on cloud_help_tickets.cloud_help_catalog_ticket_categories_id = CHCTC.id"
            ).joins(
                "inner join cloud_help_workflow_statuses CHWS on cloud_help_tickets.cloud_help_workflow_statuses_id = CHWS.id"
            ).joins(
                "inner join cloud_help_workflows CHW on CHWS.cloud_help_workflows_id = CHW.id"
            ).joins(
                "left join cloud_help_ticket_assignments CHTA on cloud_help_tickets.id = CHTA.cloud_help_tickets_id"
            ).select(
                "cloud_help_tickets.id as id",                      "cloud_help_tickets.created_at as created_at",
                "CHCTP.name as priority",                           "CHCTT.name as type",
                "CHWS.name as status",                              "CHCTP.id as cloud_help_catalog_ticket_priorities_id",
                "CHCTT.id as cloud_help_catalog_ticket_types_id",   "CHCTC.id as cloud_help_catalog_ticket_categories_id",
                "CHWS.id as cloud_help_workflow_statuses_id",       "CHCTP.weight as priority_weight",
                "CHWS.initial as status_initial",                   "CHWS.final as status_final",
                "CHW.id as cloud_help_workflows_id",                "CHWS.number as status_number"
            )
            .where("cloud_help_tickets.id = #{id}").first.attributes

            data[:category] = category.full_path
            data[:detail_attributes] = detail.attributes
            data[:assignment_attributes] = assignment_info
            
            return data
        end

=begin
@param help_account [Account] The account associated to *current_user*
@return [Hash] Detailed information about all the tickets. Including, *priority*,
    *full* *category* *path*, *type*, *creation* *user*, *assignation* *type*
    and *workflow* *state*
@description Creates a query that selects all the tickets information from several tables
    and returns it in a hash
@example
    tickets_info = CloudHelp::Ticket.detailed_info(current_user.account)
    puts tickets_info.to_json
    # will print something like: [
    #    {
    #        "id":1,                     "created_at":"2020-01-08T16:23:10.976Z",
    #        "priority":"Low",           "type":"Issue",
    #        "state":"created",          "category":"Company System",
    #        "assignation_type":null,    "subject":"Testing Ticket"
    #    },{
    #        "id":2,                     "created_at":"2020-01-08T16:43:30.470Z",
    #        "priority":"Low",           "type":"Issue",
    #        "state":"closed",           "category":"Company System",
    #        "assignation_type":"user",  "subject":"Testin"
    #    },{
    #        "id":3,                     "created_at":"2020-01-09T18:08:27.622Z",
    #        "priority":"Low",           "type":"Change Request",
    #        "state":"In Progress",      "category":"Company System, Books Module",
    #        "assignation_type":null,    "subject":"Testing"
    #    }
    #]
=end
        def self.list(help_account)
            Ticket.joins(
                "inner join cloud_help_ticket_details CHTD on cloud_help_tickets.id = CHTD.cloud_help_tickets_id"
            ).joins(
                "inner join cloud_help_catalog_ticket_priorities CHCTP on cloud_help_tickets.cloud_help_catalog_ticket_priorities_id = CHCTP.id"
            ).joins(
                "inner join cloud_help_catalog_ticket_types CHCTT on cloud_help_tickets.cloud_help_catalog_ticket_types_id = CHCTT.id"
            ).joins(
                "inner join cloud_help_catalog_ticket_categories CHCTC on cloud_help_tickets.cloud_help_catalog_ticket_categories_id = CHCTC.id"
            ).joins(
                "inner join cloud_help_workflow_statuses CHWS on cloud_help_tickets.cloud_help_workflow_statuses_id = CHWS.id"
            ).joins(
                "left join cloud_help_ticket_assignments CHTA on cloud_help_tickets.id = CHTA.cloud_help_tickets_id"
            ).select(
                "id",                                           "CHCTP.name as priority",
                "CHCTT.name as type",                           "CHWS.name as state",
                "CHCTC.name as category",                        "CHTA.assignation_type",
                "subject",                                      "CHCTC.id as cloud_help_catalog_ticket_categories_id",
                "created_at"
            ).where(
                "cloud_help_tickets.cloud_help_accounts_id = #{help_account.id}"
            ).map do |ticket|
                ticket.attributes.merge({
                    assignation_type: Ticket::Assignment.assignation_types.key(ticket[:assignation_type]),
                    category: Catalog::TicketCategory.find(ticket[:cloud_help_catalog_ticket_categories_id]).full_path
                })
            end
        end

        private

=begin
@return [Hash] Assignment information about this ticket
@description Retrievies and returns assignment information about this ticket.
    If there is no assigment, returns a hash containing a "none" in the
    *assignation_type* attribute
@todo Implement support for *team* assigmation type
@example 
    puts self.assignation_info
    #will print something similar to {
    #    assignable_name: "john.doe@email.com",
    #    assignation_type: "user"
    #}
=end
        def assignment_info
            return {
                assignation_type: 'none'
            } unless assignment

            if assignment.user?
                assignment.attributes.merge({
                    assignable_name: assignment.user.email
                })
            end
        end

=begin
@return [void]
@description After a *ticket* is updated, this method triggers. It checks for the changes
    made and based on them, adds entries to the timeline and notifies users. The possible changes are:
    - A change in workflow
    - A priority change
    - A type change
    - A category change
    - A deadline added
@example
    ticket = CloudHelp::Ticket.first
    ticket.update(detail_attributes: {cloud_help_catalog_ticket_priorities_id: 4})
    # after the update, this method is executed automatically
=end
        def after_update_actions
            super
            
            workflow_change = saved_changes["cloud_help_workflow_statuses_id"]
            if workflow_change
                if Workflow::Status.find(workflow_change[0]).final
                    errors.add(:base, :ticket_already_closed)
                    raise ActiveRecord::RecordInvalid, self
                end
                action_verify_workflow(workflow_change[0], workflow_change[1])
            else
                if status.final
                    errors.add(:base, :ticket_already_closed)
                    raise ActiveRecord::RecordInvalid, self
                end
            end
            
            priority_change = saved_changes["cloud_help_catalog_ticket_priorities_id"]
            if priority_change
                action_register_priority_change(priority_change[0], priority_change[1])
            end
            
            type_change = saved_changes["cloud_help_catalog_ticket_types_id"]
            if type_change
                action_register_type_transfer(type_change[0], type_change[1])
            end
            
            category_change = saved_changes["cloud_help_catalog_ticket_categories_id"]
            if category_change
                action_register_category_transfer(category_change[0], category_change[1])
            end

            if type_change || category_change
                action_assign_new_workflow
            end

            deadline_change = detail.saved_changes["deadline"]
            if deadline_change
                action_register_ticket_deadline
            end
        end

=begin
@return [void]
@description If this ticket changes *state*, 
    a new entry is recorded to the timeline and a notification is sent to
    the subscribers. Both the timeline entry and the notification change
    if the ticket changed to a *closed* state or not
@example
    ticket = CloudHelp::Ticket.first
    ticket.update({ detail_attributes: { cloud_help_ticket_workflow_details_id: 4 } })
    # the *after_update_actions* method will call this method after the update
=end
        def action_verify_workflow(old_status_id, new_status_id)

            old_workflow_status = Workflow::Status.find(old_status_id)
            new_workflow_status = Workflow::Status.find(new_status_id)

            # If both statuses are initial, this is a transfer
            if old_workflow_status.initial && new_workflow_status.initial
                return
            end

            unless old_workflow_status.next_statuses.split("|").include? new_workflow_status.number.to_s
                errors.add(:base, :invalid_workflow_transition)
                raise ActiveRecord::RecordInvalid, self
            end

            timeline_action = Ticket::Timeline.actions[:state_changed]
            timeline_description = I18n.t(
                'activerecord.models.cloud_help/ticket/timeline.actions.state_changed',
                old_state_name: old_workflow_status.name,
                new_state_name: new_workflow_status.name
            )
            message = I18n.t(
                'activerecord.models.cloud_help_ticket.updated.workflow',
                ticket_id: id,
                state_name: new_workflow_status.name
            )

            if new_workflow_status.final
                timeline_action = Ticket::Timeline.actions[:closed]
                timeline_description = I18n.t(
                    'activerecord.models.cloud_help/ticket/timeline.actions.closed',
                    id: id
                )
                message = I18n.t(
                    'activerecord.models.cloud_help_ticket.updated.closed',
                    ticket_id: id
                )
            end

            timelines.create( action: timeline_action, description: timeline_description )
            Ticket::Subscriber.notify_subscribers(self, message, :workflow_updated)
        end

=begin
@return [void]
@description If the type of this *ticket* is changed, 
    a new entry is recorded to the timeline. Notifications are sent in 
    the *action_assign_new_workflow* method.
@example
    ticket = CloudHelp::Ticket.first
    ticket.update({ detail_attributes: { cloud_help_catalog_ticket_types_id: 1 } })
    # the *after_update_actions* method will call this method after the update
=end
        def action_register_type_transfer(old_type, new_type)
            old_type = Catalog::TicketType.find(old_type)
            new_type = Catalog::TicketType.find(new_type)
            
            # Adding type transfer to timeline
            timelines.create(
                action: Ticket::Timeline.actions[:type_transferred],
                description: I18n.t(
                    'activerecord.models.cloud_help/ticket/timeline.actions.type_transferred',
                    old_type_name: old_type.name,
                    new_type_name: new_type.name
                )
            )
        end

=begin
@return [void]
@description If the category of this *ticket* is changed, 
    a new entry is recorded to the timeline. Notifications are sent in 
    the *action_assign_new_workflow* method.
@example
    ticket = CloudHelp::Ticket.first
    ticket.update({ detail_attributes: { cloud_help_catalog_ticket_categories: 1 } })
    # the *after_update_actions* method will call this method after the update
=end
        def action_register_category_transfer(old_category, new_category)
            old_category = Catalog::TicketCategory.find(old_category)
            new_category = Catalog::TicketCategory.find(new_category)
            
            # Adding category transfer to timeline
            timelines.create(
                action: Ticket::Timeline.actions[:category_transferred],
                description: I18n.t(
                    'activerecord.models.cloud_help/ticket/timeline.actions.category_transferred',
                    old_category_name: old_category.name,
                    new_category_name: new_category.name
                )
            )
        end

=begin
@return [void]
@description If the category or the tipe of this *ticket* are changed,
    a new workflow detail, associated to the *initial* *state*, is assigned.
    If this update fails, a rollback is ussued and a error message is added to
    this *ticket*'s *errors* attribute. If the update is successful, a notification is sent
    to all subscribers
@example
    ticket = CloudHelp::Ticket.first
    ticket.update({ detail_attributes: { cloud_help_catalog_ticket_categories: 1 } })
    # the *after_update_actions* method will call this method after the update
=end
        def action_assign_new_workflow
            assignment.destroy if assignment
            set_workflow(true)
            if save
                message = I18n.t(
                    'activerecord.models.cloud_help_ticket.updated.transferred',
                    ticket_id: id,
                    type_name: type.name,
                    category_name: category.name
                )
                Ticket::Subscriber.notify_subscribers(self, message, :type_category_updated)
                return true
            else
                raise ActiveRecord::RecordInvalid, self
            end
        end

=begin
@return [void]
@description If this ticket's priority is changed, 
    a new entry is recorded to the timeline and a notification is sent to
    the subscribers. The messages change depending if the priority weight is
    increased or decreased
@example
    ticket = CloudHelp::Ticket.first
    ticket.update({ detail_attributes: { cloud_help_catalog_ticket_priorities_id: 4 } })
    # the *after_update_actions* method will call this method after the update
=end
        def action_register_priority_change(old_priority, new_priority)
            old_priority = Catalog::TicketPriority.find(old_priority)
            new_priority = Catalog::TicketPriority.find(new_priority)

            action = :priority_decreased
            timeline_translation = 'activerecord.models.cloud_help/ticket/timeline.actions.priority_decreased'
            notification_translation = 'activerecord.models.cloud_help_ticket.updated.descalated'

            if old_priority.weight < new_priority.weight
                action = :priority_increased
                timeline_translation = 'activerecord.models.cloud_help/ticket/timeline.actions.priority_increased'
                notification_translation = 'activerecord.models.cloud_help_ticket.updated.escalated'
            end

            timelines.create(
                action: Ticket::Timeline.actions[action],
                description: I18n.t(
                    timeline_translation,
                    old_priority_name: old_priority.name,
                    old_priority_weight: old_priority.weight,
                    new_priority_name: new_priority.name,
                    new_priority_weight: new_priority.weight
                )
            )

            assignment.destroy if assignment

            message = I18n.t(
                notification_translation,
                ticket_id: id,
                priority_name: new_priority.name
            )
            Ticket::Subscriber.notify_subscribers(self, message, :priority_updated)
        end

=begin
@return [void]
@description If this ticket's deadline is changed, 
    a new entry is recorded to the timeline and a notification is sent to
    the subscribers. Also, an entry is recorded in the *CloudDriver* module, if it
    exists. If there is no user assigned, an error message is added to this
    *ticket*'s *errors* attribute, and an rollback is issued
@example
    ticket = CloudHelp::Ticket.first
    ticket.update({ detail_attributes: { deadline: Datetime.now } })
    # the *after_update_actions* method will call this method after the update
=end
        def action_register_ticket_deadline
            # Adding deadline to timeline
            timelines.create(
                action: Ticket::Timeline.actions[:deadline_established],
                description: I18n.t(
                    'activerecord.models.cloud_help/ticket/timeline.actions.deadline_established',
                    date: detail.deadline
                )
            )

            message = I18n.t(
                'activerecord.models.cloud_help_ticket.updated.deadline',
                ticket_id: id,
                date: detail.deadline
            )
            Ticket::Subscriber.notify_subscribers(self, message, :deadline_updated)
        end 
    end
end
