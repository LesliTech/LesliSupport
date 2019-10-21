module CloudHelp
    class Ticket::Detail < ApplicationRecord
        belongs_to :ticket, inverse_of: :detail, foreign_key: 'cloud_help_tickets_id'
        belongs_to :type, class_name: 'CloudHelp::TicketType', foreign_key: 'cloud_help_ticket_types_id'
        belongs_to :state, class_name: 'CloudHelp::TicketState', foreign_key: 'cloud_help_ticket_states_id'
    end
end
