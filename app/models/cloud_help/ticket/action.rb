module CloudHelp
    class Ticket::Action < CloudObject::Action
        belongs_to :cloud_object, class_name: "CloudHelp::Ticket", foreign_key: 'cloud_help_tickets_id'
    end
end
