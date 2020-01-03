module CloudHelp
    class TicketType < ApplicationRecord
        belongs_to :account, class_name: 'CloudHelp::Account', foreign_key: 'cloud_help_accounts_id'
        
        has_many :details, class_name: 'CloudHelp::Ticket::Detail', foreign_key: 'cloud_help_ticket_types_id'
        has_many :workflows, class_name: 'CloudHelp::TicketWorkflow',  foreign_key: 'cloud_help_ticket_types_id', dependent: :destroy

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
