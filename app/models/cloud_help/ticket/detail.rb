module CloudHelp
    class Ticket::Detail < ApplicationRecord
        belongs_to :ticket, foreign_key: 'cloud_help_tickets_id'
    end
end
