module LesliSupport
    class Ticket::Action < Lesli::Items::Action
        belongs_to :item, class_name: "LesliSupport::Ticket", foreign_key: "ticket_id"
        belongs_to :user, class_name: "Lesli::User"
    end
end
