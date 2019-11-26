module CloudHelp
    class Ticket  < ApplicationRecord

        belongs_to :account, class_name: 'CloudHelp::Account', foreign_key: 'cloud_help_accounts_id'
        belongs_to :user, class_name: 'User', foreign_key: 'users_id'

        has_many :discussions, foreign_key: 'cloud_help_tickets_id'
        has_many :actions, foreign_key: 'cloud_help_tickets_id'
        has_many :files, foreign_key: 'cloud_help_tickets_id'

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
                "inner join cloud_help_ticket_workflows CHTW on CHTD.cloud_help_ticket_types_id = CHTW.id"
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
                "CHTW.id",
                "CHTC.id as cloud_help_ticket_categories_id",
                "CHTS.id"
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
        

    end
end
