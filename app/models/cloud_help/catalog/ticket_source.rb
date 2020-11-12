module CloudHelp
    class Catalog::TicketSource < ApplicationLesliRecord
  
        belongs_to :account,  class_name: "CloudHelp::Account",   foreign_key: "cloud_help_accounts_id"
        has_many :tickets,    class_name: "CloudHelp::Ticket",    foreign_key: "cloud_help_catalog_ticket_sources_id"
        
        def self.cloud_help_source(account)
            return Catalog::TicketSource.find_by(account: account, name: "CloudHelp")
        end
    end
  end
  