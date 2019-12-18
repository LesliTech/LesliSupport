module CloudHelp
    class Ticket  < ApplicationRecord 
        include Subscribable

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
        accepts_nested_attributes_for :assignment, update_only: true
        accepts_nested_attributes_for :subscribers, allow_destroy: true

        after_update :after_update_actions


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


        def set_workflow
            detail.workflow = TicketWorkflow.find_by(
                ticket_type: detail.type,
                ticket_category: detail.category,
                ticket_state: TicketState.initial_state
            )
        end


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
                    inner join cloud_help_ticket_workflows CHTW on CHTD.cloud_help_ticket_types_id = CHTW.cloud_help_ticket_types_id and 
                    CHTD.cloud_help_ticket_categories_id = CHTW.cloud_help_ticket_categories_id and 
                    CHTD.cloud_help_ticket_workflows_id = CHTW.id
                "
            ).joins(
                "inner join cloud_help_ticket_states CHTS on CHTW.cloud_help_ticket_states_id = CHTS.id"
            ).joins( :user ).select(
                "users.email as email",                         "subject",
                "description",                                  "CHTD.tags",
                "CHTP.name as priority",                        "CHTT.name as type",
                "CHTS.name as state",                           "CHTP.id as cloud_help_ticket_priorities_id",
                "CHTT.id as cloud_help_ticket_types_id",        "CHTW.id as cloud_help_ticket_workflows_id",
                "CHTC.id as cloud_help_ticket_categories_id",   "CHTS.id as cloud_help_ticket_states_id",
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
                    inner join cloud_help_ticket_workflows CHTW on CHTD.cloud_help_ticket_types_id = CHTW.cloud_help_ticket_types_id and 
                    CHTD.cloud_help_ticket_categories_id = CHTW.cloud_help_ticket_categories_id and 
                    CHTD.cloud_help_ticket_workflows_id = CHTW.id
                "
            ).joins(
                "inner join cloud_help_ticket_states CHTS on CHTW.cloud_help_ticket_states_id = CHTS.id"
            ).joins(
                "left join cloud_help_ticket_assignments CHTA on cloud_help_tickets.id = CHTA.cloud_help_tickets_id"
            ).select(
                "id",                                           "CHTP.name as priority",
                "CHTT.name as type",                           "CHTS.name as state",
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

        
        def after_update_actions

            workflow_change = detail.saved_changes["cloud_help_ticket_workflows_id"]
            if workflow_change
                if TicketWorkflow.find(workflow_change[0]).ticket_state.is_final?
                    errors.add(:base, :ticket_already_closed)
                    raise ActiveRecord::RecordInvalid, self
                end
                action_verify_ticket_workflow(workflow_change[0], workflow_change[1])
            else
                if detail.workflow.ticket_state.is_final?
                    errors.add(:base, :ticket_already_closed)
                    raise ActiveRecord::RecordInvalid, self
                end
            end

            if assignment
                assignment_change = assignment.saved_changes["users_id"]
                if assignment_change
                    action_register_assignment_change()
                end
            end
            
            priority_change = detail.saved_changes["cloud_help_ticket_priorities_id"]
            if priority_change
                action_register_priority_change(priority_change[0], priority_change[1])
            end
            
            type_change = detail.saved_changes["cloud_help_ticket_types_id"]
            category_change = detail.saved_changes["cloud_help_ticket_categories_id"]

            if type_change || category_change
                action_register_transfer(type_change[0], type_change[1], category_change[0], category_change[1])
            end

            if detail.saved_changes["deadline"] 
                action_register_ticket_deadline
            end
                
        end

        def action_register_assignment_change
            timelines.create(
                action: Ticket::Timeline.actions[:assigned_to_user],
                description: I18n.t(
                    'activerecord.models.cloud_help/ticket/timeline.actions.assigned_to_user',
                    user: assignment.user.email
                )
            )

            message = I18n.t(
                'activerecord.models.cloud_help_ticket.updated.assigned',
                ticket_id: id,
                user: assignment.user.email
            )
            notify_subscribers(message, :assignment_updated)
        end

        def action_verify_ticket_workflow(old_workflow_id, new_workflow_id)
            old_workflow = TicketWorkflow.find(old_workflow_id)
            new_workflow = TicketWorkflow.find_by(
                id: new_workflow_id,
                cloud_help_ticket_categories_id: detail.cloud_help_ticket_categories_id,
                cloud_help_ticket_types_id: detail.cloud_help_ticket_types_id
            )
            unless new_workflow
                errors.add(:base, :invalid_workflow_transition)
                raise ActiveRecord::RecordInvalid, self
            end

            timeline_action = Ticket::Timeline.actions[:state_changed]
            timeline_description = I18n.t(
                'activerecord.models.cloud_help/ticket/timeline.actions.state_changed',
                old_state_name: old_workflow.ticket_state.name,
                new_state_name: new_workflow.ticket_state.name
            )
            message = I18n.t(
                'activerecord.models.cloud_help_ticket.updated.workflow',
                ticket_id: id,
                state_name: new_workflow.ticket_state.name
            )

            if new_workflow.ticket_state.is_final?
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
            notify_subscribers(message, :workflow_updated)
        end


        def action_register_transfer(old_type, new_type, old_category, new_category)
            old_type = TicketType.find(old_type)
            new_type = TicketType.find(new_type)
            old_category = TicketCategory.find(old_category)
            new_category = TicketCategory.find(new_category)
            new_workflow = TicketWorkflow.find_by(ticket_type: new_type, ticket_category: new_category, ticket_state: TicketState.initial_state)
            
            if detail.update(workflow: new_workflow)
                
                # Adding type transfer to timeline
                timelines.create(
                    action: Ticket::Timeline.actions[:type_transferred],
                    description: I18n.t(
                        'activerecord.models.cloud_help/ticket/timeline.actions.type_transferred',
                        old_type_name: old_type.name,
                        new_type_name: new_type.name
                    )
                ) unless old_type.id == new_type.id

                # Adding category transfer to timeline
                timelines.create(
                    action: Ticket::Timeline.actions[:category_transferred],
                    description: I18n.t(
                        'activerecord.models.cloud_help/ticket/timeline.actions.category_transferred',
                        old_category_name: old_category.name,
                        new_category_name: new_category.name
                    )
                ) unless old_category.id == new_category.id

                assignment.destroy
                message = I18n.t(
                    'activerecord.models.cloud_help_ticket.updated.transferred',
                    ticket_id: id,
                    type_name: new_type.name,
                    category_name: new_category.name
                )
                notify_subscribers(message, :type_category_updated)

                return true
            else
                raise ActiveRecord::RecordInvalid, self
            end
        end


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
            if assignment
                assignment.destroy
            end
            message = I18n.t(
                notification_translation,
                ticket_id: id,
                priority_name: new_priority.name
            )
            notify_subscribers(message, :priority_updated)
        end


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
                notify_subscribers(message, :deadline_updated)
            else
                errors.add(:base, :cannot_add_deadline_without_assigned_user)
                raise ActiveRecord::RecordInvalid, self
            end
        end


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


    end
end
