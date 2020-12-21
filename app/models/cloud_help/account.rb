=begin

Copyright (c) 2020, all rights reserved.

All the information provided by this platform is protected by international laws related  to 
industrial property, intellectual property, copyright and relative international laws. 
All intellectual or industrial property rights of the code, texts, trade mark, design, 
pictures and any other information belongs to the owner of this platform.

Without the written permission of the owner, any replication, modification,
transmission, publication is strictly forbidden.

For more information read the license file including with this software.

// · ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~
// · 

=end
module CloudHelp
    class Account < ApplicationRecord
        belongs_to :account, class_name: "::Account", foreign_key: "id"
        
        
        has_many :workfolows,           class_name: "CloudHelp::Workflow",                  foreign_key: "cloud_help_accounts_id"
        has_many :tickets,              class_name: "CloudHelp::Ticket",                    foreign_key: "cloud_help_accounts_id"
        has_many :ticket_categories,    class_name: "CloudHelp::Catalog::TicketCategory",   foreign_key: "cloud_help_accounts_id"
        has_many :ticket_priorities,    class_name: "CloudHelp::Catalog::TicketPriority",   foreign_key: "cloud_help_accounts_id"
        has_many :ticket_types,         class_name: "CloudHelp::Catalog::TicketType",       foreign_key: "cloud_help_accounts_id"
        has_many :ticket_sources,       class_name: "CloudHelp::Catalog::TicketSource",     foreign_key: "cloud_help_accounts_id"
        has_many :slas,                 class_name: "CloudHelp::Sla",                       foreign_key: "cloud_help_accounts_id"

        after_create :initialize_account

=begin
@return [void]
@description Initializes all required information for this account to work properly
@example
    house_account = CloudHouse::Account.new(::Account.find(1))
    # Rails will automatically execute this method after the account is created
=end
        def initialize_account
            Workflow.initialize_data(self)
            Dashboard.initialize_data(self)
            Catalog.initialize_data(self)
        end

    end
end
