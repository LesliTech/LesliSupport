module CloudHelp
    class Ticket::Detail < ApplicationRecord
        belongs_to :ticket, inverse_of: :detail, foreign_key: 'cloud_help_tickets_id'
        belongs_to :type, class_name: 'CloudHelp::TicketType', foreign_key: 'cloud_help_ticket_types_id'
        belongs_to :workflow, class_name: 'CloudHelp::TicketWorkflow', foreign_key: 'cloud_help_ticket_workflows_id'
        belongs_to :priority, class_name: 'CloudHelp::TicketPriority', foreign_key: 'cloud_help_ticket_priorities_id'
        belongs_to :category, class_name: 'CloudHelp::TicketCategory', foreign_key: 'cloud_help_ticket_categories_id'
        belongs_to :source, class_name: 'CloudHelp::TicketSource', foreign_key: 'cloud_help_ticket_sources_id'
    end
end
