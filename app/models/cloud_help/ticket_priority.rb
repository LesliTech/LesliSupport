module CloudHelp
    class TicketPriority < ApplicationRecord

        belongs_to :account, class_name: 'CloudHelp::Account', foreign_key: 'cloud_help_accounts_id'
        
        has_many :details, class_name: 'CloudHelp::Ticket::Detail', foreign_key: 'cloud_help_ticket_priorities_id'

        def destroy
            begin
                super
            rescue ActiveRecord::InvalidForeignKey
                errors.add(:base, :foreign_key_prevents_destruction)
                false
            end
        end
        
    end
end
