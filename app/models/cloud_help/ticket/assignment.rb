module CloudHelp
    class Ticket::Assignment < ApplicationRecord
        include ActiveModel::Dirty
        
        belongs_to :ticket, inverse_of: :assignment, foreign_key: 'cloud_help_tickets_id'
        belongs_to :user, class_name: 'User', foreign_key: 'users_id'

        enum assignation_type: [:user, :team]
        validates :assignation_type, presence: true, inclusion: { in: :assignation_type }
    end
end
