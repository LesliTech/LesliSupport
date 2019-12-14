module CloudHelp
  class Ticket::Subscriber < CloudObject::Subscriber
    belongs_to :ticket, class_name: "CloudHelp::Ticket", foreign_key: 'cloud_help_tickets_id'
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
        :assignment_updated,
        :deadline_updated
    ]
  end
end
