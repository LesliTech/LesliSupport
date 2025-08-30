module LesliSupport
    class Ticket::Discussion < Lesli::Items::Discussion
        belongs_to :item, class_name: "LesliSupport::Ticket", foreign_key: "ticket_id"
        belongs_to :user, class_name: "Lesli::User"

        #belongs_to :parent, class_name: "Discussion", optional: true
        #has_many :children, class_name: "Discussion", foreign_key: "parent_id"
    end
end
