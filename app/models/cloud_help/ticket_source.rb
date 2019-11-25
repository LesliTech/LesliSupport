module CloudHelp
  class TicketSource < ApplicationRecord

    belongs_to :account, class_name: 'CloudHelp::Account', foreign_key: 'cloud_help_accounts_id'
    
    has_many :details, class_name: 'CloudHelp::Ticket::Detail', foreign_key: 'cloud_help_ticket_sources_id'

    # CloudHelp platform is record #1 in the database
    def self.cloud_help_source
        return TicketSource.find(1)
    end
  end
end
