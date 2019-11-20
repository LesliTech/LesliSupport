module CloudHelp
  class TicketSource < ApplicationRecord

    belongs_to :account, class_name: 'CloudHelp::Account', foreign_key: 'cloud_help_accounts_id'
    
    has_many :details, class_name: 'CloudHelp::Ticket::Detail', foreign_key: 'cloud_help_ticket_sources_id'
  end
end
