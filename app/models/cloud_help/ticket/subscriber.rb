module CloudHelp
  class Ticket::Subscriber < ApplicationRecord
    belongs_to :ticket, class_name: "CloudHelp::Ticket", foreign_key: 'cloud_help_tickets_id'
    belongs_to :user, class_name: "User", foreign_key: "users_id"

    enum event: [
        :ticket_created,
        :ticket_closed,
        :comment_created,
        :action_created,
        :file_created,
        :activity_created,
        :workflow_updated,
        :priority_updated,
        :type_category_updated,
        :assignment_updated
    ]
    
    validates :event, presence: true, inclusion: { in: :event }
  end
end
