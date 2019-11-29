module CloudHelp
    class Ticket  < ApplicationRecord

        belongs_to :account, class_name: 'CloudHelp::Account', foreign_key: 'cloud_help_accounts_id'
        belongs_to :user, class_name: 'User', foreign_key: 'users_id'

        has_many :discussions, foreign_key: 'cloud_help_tickets_id'
        has_many :actions, foreign_key: 'cloud_help_tickets_id'
        has_many :files, foreign_key: 'cloud_help_tickets_id'
        has_many :followers, foreign_key: 'cloud_help_tickets_id'

        has_one :detail, inverse_of: :ticket, autosave: true, foreign_key: 'cloud_help_tickets_id'
        accepts_nested_attributes_for :detail

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
            ).joins(
                :user
            ).select(
                "users.email as email",
                "subject",
                "description",
                "tags",
                "CHTP.name as priority",
                "CHTT.name as type",
                "CHTS.name as state",
                "CHTP.id as cloud_help_ticket_priorities_id",
                "CHTT.id as cloud_help_ticket_types_id",
                "CHTW.id as cloud_help_ticket_workflows_id",
                "CHTC.id as cloud_help_ticket_categories_id",
                "CHTS.id as cloud_help_ticket_states_id"
            )
            .where("cloud_help_tickets.id = #{id}").first.attributes
            { 
                id: id,
                created_at: created_at,
                detail_attributes: data.merge(
                    category: TicketCategory.get_category_path(detail.category.id)
                )
            }
        end

        def self.detailed_info(help_account)
            tickets = help_account.tickets.all

            tickets.map do |ticket|
                detail = ticket.detail
                ticket.attributes.merge({
                    subject: detail.subject,
                    type: detail.type.name,
                    state: detail.workflow.ticket_state.name,
                    category: detail.category.name,
                    priority: detail.priority.name
                })
            end
        end
        
        def escalate
            change_priority(false)
        end

        def descalate
            change_priority(true)
        end

        def transfer(help_account, type_id, category_id)
            new_type = TicketType.find_by(account: help_account, id: type_id)
            new_category = TicketCategory.find_by(account: help_account, id: category_id)
            unless (new_type && new_category)
                errors.add(:base, :transfer_type_or_category_missing)
                return false
            end
            new_workflow = TicketWorkflow.find_by(ticket_type: new_type, ticket_category: new_category, ticket_state: TicketState.initial_state)
            detail.update(type: new_type, category: new_category, workflow: new_workflow)
        end

        def add_follower(user)
            followers.create(user: user)
        end

        def notify_followers(subject)
            followers.each do |follower|
                Courier::Bell::NotificationJob.perform_now(
                    user: follower.user,
                    subject: subject,
                    href: "/help/tickets/#{id}"
                )
            end
        end

        private

        # Change priority is used by escalate and descalate. to_lower indicates if the priority goes higher or lower
        def change_priority(to_lower)

            sort_order = :asc
            comparison = '>'

            if to_lower
                sort_order = :desc
                comparison = '<'
            end

            current_priority = detail.priority
            new_priority = TicketPriority.where(
                account: current_priority.account
            ).where(
                "cloud_help_ticket_priorities.weight #{comparison} #{current_priority.weight}"
            ).order(
                weight: sort_order
            ).first
            unless new_priority
                errors.add(:base, :ticket_at_max_priority)
                return false
            end
            detail.update(priority: new_priority)

        end

    end
end
