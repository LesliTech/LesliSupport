module CloudHelp
    class Ticket::File < CloudObject::File
        belongs_to :cloud_object, class_name: "CloudHelp::Ticket", foreign_key: 'cloud_help_tickets_id'
    end
end
