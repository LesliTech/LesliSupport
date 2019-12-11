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

        before_save :before_save_actions
        after_save :after_save_actions

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
            if detail.workflow.ticket_state.is_final?
                errors.add(:base, :ticket_already_closed)
                return false
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
                "subject",                                      "CHTC.id as cloud_help_ticket_categories_id"
            ).where(
                "cloud_help_tickets.cloud_help_accounts_id = #{help_account.id}"
            ).map do |ticket|
                ticket.attributes.merge({
                    assignation_type: Ticket::Assignment.assignation_types.key(ticket[:assignation_type]),
                    category: TicketCategory.find(ticket[:cloud_help_ticket_categories_id]).full_path
                })
            end
        end

        def update_workflow(new_workflow_node)
            if detail.update(workflow: new_workflow_node)
                
                timeline_action = Ticket::Timeline.actions[:state_changed]
                timeline_description = I18n.t(
                    'activerecord.models.cloud_help/ticket/timeline.actions.state_changed',
                    old_state_name: detail.workflow.ticket_state.name,
                    new_state_name: new_workflow_node.ticket_state.name
                )

                if new_workflow_node.ticket_state.is_final?
                    timeline_action = Ticket::Timeline.actions[:closed]
                    timeline_description = I18n.t(
                        'activerecord.models.cloud_help/ticket/timeline.actions.closed',
                        id: id
                    )
                end

                timelines.create( action: timeline_action, description: timeline_description )
                return true
            else
                return false
            end
        end

        def transfer(help_account, type_id, category_id)
            current_type = detail.type
            current_category = detail.category
            new_type = TicketType.find_by(account: help_account, id: type_id)
            new_category = TicketCategory.find_by(account: help_account, id: category_id)
            unless (new_type && new_category)
                errors.add(:base, :transfer_type_or_category_missing)
                return false
            end
            new_workflow = TicketWorkflow.find_by(ticket_type: new_type, ticket_category: new_category, ticket_state: TicketState.initial_state)
            
            if detail.update(type: new_type, category: new_category, workflow: new_workflow)
                # Adding type transfer to timeline
                if current_type.id != new_type.id
                    timelines.create(
                        action: Ticket::Timeline.actions[:type_transferred],
                        description: I18n.t(
                            'activerecord.models.cloud_help/ticket/timeline.actions.type_transferred',
                            old_type_name: current_type.name,
                            new_type_name: new_type.name
                        )
                    )
                end
                # Adding category transfer to timeline
                if current_category.id != new_category.id
                    timelines.create(
                        action: Ticket::Timeline.actions[:category_transferred],
                        description: I18n.t(
                            'activerecord.models.cloud_help/ticket/timeline.actions.category_transferred',
                            old_category_name: current_category.name,
                            new_category_name: new_category.name
                        )
                    )
                end
                assignment.destroy
                return true
            else
                return false
            end
        end

        def assign_to_user(params)
            return false unless update(params)
            timelines.create(
                action: Ticket::Timeline.actions[:assigned_to_user],
                description: I18n.t(
                    'activerecord.models.cloud_help/ticket/timeline.actions.assigned_to_user',
                    user: assignment.user.email
                )
            )
        end

        private

        def before_save_actions
            if detail.deadline_changed?
                action_register_ticket_deadline
            end
        end

        def after_save_actions
            priority_change = detail.saved_changes["cloud_help_ticket_priorities_id"]
            if priority_change && priority_change.length > 1
                action_register_priority_change(priority_change[0], priority_change[1])
            end
        end

        def action_register_priority_change(old_priority, new_priority)
            old_priority = TicketPriority.find(old_priority)
            new_priority = TicketPriority.find(new_priority)

            action = :priority_decreased
            timeline_translation = 'activerecord.models.cloud_help/ticket/timeline.actions.priority_decreased'
            notification_translation = 'cloud_help.controllers.tickets.notifications.updated.descalated'

            if old_priority.weight < new_priority.weight
                action = :priority_increased
                timeline_translation = 'activerecord.models.cloud_help/ticket/timeline.actions.priority_increased'
                notification_translation = 'cloud_help.controllers.tickets.notifications.updated.escalated'
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
            assignment.destroy
            
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
            else
                errors.add(:base, :cannot_add_deadline_without_assigned_user)
                throw :abort
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
