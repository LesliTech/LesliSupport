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
    class Ticket  < ApplicationRecord

        belongs_to :account, class_name: 'CloudHelp::Account', foreign_key: 'cloud_help_accounts_id'
        belongs_to :user, class_name: 'User', foreign_key: 'users_id'

        has_many :discussions, foreign_key: 'cloud_help_tickets_id'
        has_many :actions, foreign_key: 'cloud_help_tickets_id'
        has_many :files, foreign_key: 'cloud_help_tickets_id'
        has_many :subscribers, foreign_key: 'cloud_help_tickets_id'
        has_many :timelines, foreign_key: 'cloud_help_tickets_id'

        has_one :detail, inverse_of: :ticket, autosave: true, foreign_key: 'cloud_help_tickets_id'
        has_one :assignment, inverse_of: :ticket, autosave: true, foreign_key: 'cloud_help_tickets_id'  

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
            cloud_help_ticket_priorities_id: 1,
            cloud_help_ticket_categories_id: 1,
            cloud_help_ticket_types_id: 1
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
@return [void]
@description Adds the "workflow_detail" attribute to an existing *ticket*.
    It is the *detail* associated to the initial *state*, based on the
    *ticket*'s *type*/*priority* 
@example
    ticket_params = {
        detail_attributes: {
            cloud_help_ticket_priorities_id: 1,
            cloud_help_ticket_categories_id: 1,
            cloud_help_ticket_types_id: 1
        }
    }
    ticket = CloudHelp::Ticket.new(ticket_params)
    ticket.set_workflow_detail
    if ticket.save
        responseWithSuccessful
    else
        responseWithError(ticket.errors.full_messages.to_sentence)
    end
=end
        def set_workflow_detail
            workflow_assignment = TicketWorkflowAssignment.find_by(
                ticket_type: detail.type,
                ticket_category: detail.category,
                account: account
            )
            workflow = workflow_assignment.ticket_workflow

            detail.workflow_detail = TicketWorkflow::Detail.find_by(
                workflow: workflow,
                workflow_state: TicketWorkflowState.initial_state(account)
            )
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
    #        cloud_help_ticket_priorities_id:2,
    #        cloud_help_ticket_types_id:2,
    #        cloud_help_ticket_workflows_id:4,
    #        cloud_help_ticket_categories_id:1,
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
                "inner join cloud_help_ticket_details CHTD on cloud_help_tickets.id = CHTD.cloud_help_tickets_id"
            ).joins(
                "inner join cloud_help_ticket_priorities CHTP on CHTD.cloud_help_ticket_priorities_id = CHTP.id"
            ).joins(
                "inner join cloud_help_ticket_types CHTT on CHTD.cloud_help_ticket_types_id = CHTT.id"
            ).joins(
                "inner join cloud_help_ticket_categories CHTC on CHTD.cloud_help_ticket_categories_id = CHTC.id"
            ).joins(
                "
                    inner join cloud_help_ticket_workflow_assignments CHTWA on 
                    CHTWA.cloud_help_ticket_types_id = CHTT.id and CHTWA.cloud_help_ticket_categories_id = CHTC.id
                "
            ).joins(
                "inner join cloud_help_ticket_workflows CHTW on CHTWA.cloud_help_ticket_workflows_id = CHTW.id"
            ).joins(
                "
                    inner join cloud_help_ticket_workflow_details CHTWD on CHTWD.cloud_help_ticket_workflows_id = CHTW.id and
                    CHTD.cloud_help_ticket_workflow_details_id = CHTWD.id
                "
            ).joins(
                "inner join cloud_help_ticket_workflow_states CHTWS on CHTWD.cloud_help_ticket_workflow_states_id = CHTWS.id"
            ).joins( :user ).select(
                "users.email as email",                         "subject",
                "description",                                  "CHTD.tags",
                "CHTP.name as priority",                        "CHTT.name as type",
                "CHTWS.name as state",                          "CHTP.id as cloud_help_ticket_priorities_id",
                "CHTT.id as cloud_help_ticket_types_id",        "CHTW.id as cloud_help_ticket_workflows_id",
                "CHTC.id as cloud_help_ticket_categories_id",   "CHTWS.id as cloud_help_ticket_workflow_states_id",
                "deadline"                                  ,   "CHTP.weight as priority_weight"
            )
            .where("cloud_help_tickets.id = #{id}").first.attributes
            return {
                id: id,
                created_at: created_at,
                detail_attributes: data.merge(
                    category: detail.category.full_path
                ),
                assignment_attributes: assignment_info
            }
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
        def self.detailed_info(help_account)
            Ticket.joins(
                "inner join cloud_help_ticket_details CHTD on cloud_help_tickets.id = CHTD.cloud_help_tickets_id"
            ).joins(
                "inner join cloud_help_ticket_priorities CHTP on CHTD.cloud_help_ticket_priorities_id = CHTP.id"
            ).joins(
                "inner join cloud_help_ticket_types CHTT on CHTD.cloud_help_ticket_types_id = CHTT.id"
            ).joins(
                "inner join cloud_help_ticket_categories CHTC on CHTD.cloud_help_ticket_categories_id = CHTC.id"
            ).joins(
                "
                    inner join cloud_help_ticket_workflow_assignments CHTWA on 
                    CHTWA.cloud_help_ticket_types_id = CHTT.id and CHTWA.cloud_help_ticket_categories_id = CHTC.id
                "
            ).joins(
                "inner join cloud_help_ticket_workflows CHTW on CHTWA.cloud_help_ticket_workflows_id = CHTW.id"
            ).joins(
                "
                    inner join cloud_help_ticket_workflow_details CHTWD on CHTWD.cloud_help_ticket_workflows_id = CHTW.id and
                    CHTD.cloud_help_ticket_workflow_details_id = CHTWD.id
                "
            ).joins(
                "inner join cloud_help_ticket_workflow_states CHTWS on CHTWD.cloud_help_ticket_workflow_states_id = CHTWS.id"
            ).joins(
                "left join cloud_help_ticket_assignments CHTA on cloud_help_tickets.id = CHTA.cloud_help_tickets_id"
            ).select(
                "id",                                           "CHTP.name as priority",
                "CHTT.name as type",                           "CHTWS.name as state",
                "CHTC.name as category",                        "CHTA.assignation_type",
                "subject",                                      "CHTC.id as cloud_help_ticket_categories_id",
                "created_at"
            ).where(
                "cloud_help_tickets.cloud_help_accounts_id = #{help_account.id}"
            ).map do |ticket|
                ticket.attributes.merge({
                    assignation_type: Ticket::Assignment.assignation_types.key(ticket[:assignation_type]),
                    category: TicketCategory.find(ticket[:cloud_help_ticket_categories_id]).full_path
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
    ticket.update(detail_attributes: {cloud_help_ticket_priorities_id: 4})
    # after the update, this method is executed automatically
=end
        def after_update_actions
            workflow_change = detail.saved_changes["cloud_help_ticket_workflow_details_id"]
            if workflow_change
                if TicketWorkflow::Detail.find(workflow_change[0]).workflow_state.is_final?
                    errors.add(:base, :ticket_already_closed)
                    raise ActiveRecord::RecordInvalid, self
                end
                action_verify_ticket_workflow(workflow_change[0], workflow_change[1])
            else
                if detail.workflow_detail.workflow_state.is_final?
                    errors.add(:base, :ticket_already_closed)
                    raise ActiveRecord::RecordInvalid, self
                end
            end
            
            priority_change = detail.saved_changes["cloud_help_ticket_priorities_id"]
            if priority_change
                action_register_priority_change(priority_change[0], priority_change[1])
            end
            
            type_change = detail.saved_changes["cloud_help_ticket_types_id"]
            if type_change
                action_register_type_transfer(type_change[0], type_change[1])
            end
            
            category_change = detail.saved_changes["cloud_help_ticket_categories_id"]
            if category_change
                action_register_category_transfer(category_change[0], category_change[1])
            end

            if type_change || category_change
                action_assign_new_workflow
            end

            if detail.saved_changes["deadline"] 
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
        def action_verify_ticket_workflow(old_workflow_detail_id, new_workflow_detail_id)

            old_workflow_detail = TicketWorkflow::Detail.find(old_workflow_detail_id)
            new_workflow_detail = TicketWorkflow::Detail.find(new_workflow_detail_id)
            unless old_workflow_detail.next_states.split("|").include? new_workflow_detail.cloud_help_ticket_workflow_states_id.to_s   
                errors.add(:base, :invalid_workflow_transition)
                raise ActiveRecord::RecordInvalid, self
            end

            timeline_action = Ticket::Timeline.actions[:state_changed]
            timeline_description = I18n.t(
                'activerecord.models.cloud_help/ticket/timeline.actions.state_changed',
                old_state_name: old_workflow_detail.workflow_state.name,
                new_state_name: new_workflow_detail.workflow_state.name
            )
            message = I18n.t(
                'activerecord.models.cloud_help_ticket.updated.workflow',
                ticket_id: id,
                state_name: new_workflow_detail.workflow_state.name
            )

            if new_workflow_detail.workflow_state.is_final?
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
    ticket.update({ detail_attributes: { cloud_help_ticket_types_id: 1 } })
    # the *after_update_actions* method will call this method after the update
=end
        def action_register_type_transfer(old_type, new_type)
            old_type = TicketType.find(old_type)
            new_type = TicketType.find(new_type)
            
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
    ticket.update({ detail_attributes: { cloud_help_ticket_categories: 1 } })
    # the *after_update_actions* method will call this method after the update
=end
        def action_register_category_transfer(old_category, new_category)
            old_category = TicketCategory.find(old_category)
            new_category = TicketCategory.find(new_category)
            
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
    ticket.update({ detail_attributes: { cloud_help_ticket_categories: 1 } })
    # the *after_update_actions* method will call this method after the update
=end
        def action_assign_new_workflow
            assignment.destroy if assignment
            category = detail.category
            type = detail.type

            workflow_assignment = TicketWorkflowAssignment.find_by(ticket_type: type, ticket_category: category)
            new_workflow = workflow_assignment.ticket_workflow
            new_workflow_detail = new_workflow.details.find_by(workflow_state: TicketWorkflowState.initial_state(account))
            if detail.update!(workflow_detail: new_workflow_detail)
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
    ticket.update({ detail_attributes: { cloud_help_ticket_priorities_id: 4 } })
    # the *after_update_actions* method will call this method after the update
=end
        def action_register_priority_change(old_priority, new_priority)
            old_priority = TicketPriority.find(old_priority)
            new_priority = TicketPriority.find(new_priority)

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
            if assignment
                Courier::Driver::Calendar.registerEvent(
                    assignment.user,
                    {
                        title:          I18n.t('activerecord.models.cloud_help_ticket.assignation_registry.title', ticket_id: id),
                        description:    I18n.t('activerecord.models.cloud_help_ticket.assignation_registry.description'),
                        time_start:     detail.deadline.to_date,
                        time_end:       detail.deadline.to_date + 1.hour,
                        url:            "/help/tickets/#{id}"
                    }
                )

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
            else
                errors.add(:base, :cannot_add_deadline_without_assigned_user)
                raise ActiveRecord::RecordInvalid, self
            end
        end
    end
end
