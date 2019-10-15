module CloudHelp
    class Ticket::Discussion < ApplicationRecord
        belongs_to :ticket, class_name: "CloudHelp::Ticket", foreign_key: 'cloud_help_tickets_id'
        belongs_to :parent, class_name: 'Discussion', optional: true
        has_many :children, class_name: 'Discussion', foreign_key: 'parent_id'
    end
end
