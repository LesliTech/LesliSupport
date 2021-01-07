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
    class Sla::Association < ApplicationRecord
        belongs_to  :sla,           class_name: "CloudHelp::Sla",                   foreign_key: "cloud_help_slas_id"
        belongs_to   :ticket_type,   class_name: "CloudHelp::Catalog::TicketType",   foreign_key: "cloud_help_catalog_ticket_types_id"


        def self.options(current_user, query)
            ticket_types = current_user.account.help.ticket_types.select(
                :id,
                :name
            )

            {
                ticket_types: ticket_types
            }
        end
    end
end
