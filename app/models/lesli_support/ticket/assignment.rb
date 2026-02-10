module LesliSupport
    class Ticket::Assignment < ApplicationRecord
        belongs_to :user, class_name: "Lesli::User"
        belongs_to :ticket, foreign_key: "ticket_id"
    end
end
