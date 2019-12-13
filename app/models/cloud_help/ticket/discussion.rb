module CloudHelp
    class Ticket::Discussion < CloudObject::Discussion
        
        belongs_to :cloud_object, class_name: "CloudHelp::Ticket", foreign_key: 'cloud_help_tickets_id'
        belongs_to :parent, class_name: 'Discussion', optional: true
        has_many :children, class_name: 'Discussion', foreign_key: 'parent_id'
        
    end
end
