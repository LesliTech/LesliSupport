module CloudHelp
  class Ticket::Follower < ApplicationRecord
    belongs_to :ticket, class_name: "CloudHelp::Ticket", foreign_key: 'cloud_help_tickets_id'
    belongs_to :user, class_name: "User", foreign_key: "users_id"
  end
end
