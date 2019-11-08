module CloudHelp
    class Ticket::File < ApplicationRecord
        belongs_to :ticket, class_name: "CloudHelp::Ticket", foreign_key: 'cloud_help_tickets_id'
        has_one_attached :file
    end
end
