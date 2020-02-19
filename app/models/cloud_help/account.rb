module CloudHelp
    class Account < ApplicationRecord
        belongs_to :account, class_name: "::Account", foreign_key: "id"
        
        
        has_many :workfolows,           class_name: "CloudHelp::Workflow",                  foreign_key: "cloud_help_accounts_id"
        has_many :tickets,              class_name: "CloudHelp::Ticket",                    foreign_key: "cloud_help_accounts_id"
        has_many :ticket_categories,    class_name: "CloudHelp::Catalog::TicketCategory",   foreign_key: "cloud_help_accounts_id"
        has_many :ticket_priorities,    class_name: "CloudHelp::Catalog::TicketPrioority",  foreign_key: "cloud_help_accounts_id"
        has_many :ticket_types,         class_name: "CloudHelp::Catalog::TicketType",       foreign_key: "cloud_help_accounts_id"
        has_many :ticket_sources,       class_name: "CloudHelp::Catalog::TicketSource",     foreign_key: "cloud_help_accounts_id"
        has_many :slas,                 class_name: "CloudHelp::Sla",                       foreign_key: "cloud_help_accounts_id"
    end
end
