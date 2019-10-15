module CloudHelp
    class Ticket::Comment < ApplicationRecord
        belongs_to :ticket, class_name: "CloudHelp::Ticket", foreign_key: 'cloud_help_tickets_id'
        belongs_to :parent, class_name: 'Comment', optional: true
        has_many :children, class_name: 'Comment', foreign_key: 'parent_id'
    end
end
