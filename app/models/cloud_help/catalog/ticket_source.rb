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
    class Catalog::TicketSource < ApplicationLesliRecord
  
        belongs_to :account,  class_name: "CloudHelp::Account",   foreign_key: "cloud_help_accounts_id"
        has_many :tickets,    class_name: "CloudHelp::Ticket",    foreign_key: "cloud_help_catalog_ticket_sources_id"
        
        def self.cloud_help_source(account)
            return Catalog::TicketSource.find_by(account: account, name: "CloudHelp")
        end
    end
  end
  