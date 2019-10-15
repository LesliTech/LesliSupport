module CloudHelp
    class Ticket::Action < ApplicationRecord
        belongs_to :ticket, class_name: "CloudHelp::Ticket", foreign_key: 'cloud_help_tickets_id'
    end
end
