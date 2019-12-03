module CloudHelp
    class Ticket::Assignment < ApplicationRecord
        belongs_to :ticket, inverse_of: :assignment, foreign_key: 'cloud_help_tickets_id'
        belongs_to :assignable, polymorphic: true
    end
end
