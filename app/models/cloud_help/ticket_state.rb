module CloudHelp
    class TicketState < ApplicationRecord
        has_many :details, class_name: 'CloudHelp::Ticket::Detail', foreign_key: 'cloud_help_ticket_types_id'
    end
end
