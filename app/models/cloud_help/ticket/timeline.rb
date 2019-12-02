module CloudHelp
    class Ticket::Timeline < ApplicationRecord
        belongs_to :ticket, class_name: 'CloudHelp::Ticket', foreign_key: 'cloud_help_tickets_id'
    
        enum action: [:state_changed, :priority_increased, :priority_decreased, :category_transferred, :type_transferred, :created, :closed]
    end
end
