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
    class Workflow::Association < CloudObject::Workflow::Association

        belongs_to :workflow, class_name: "Workflow", foreign_key: "cloud_help_workflows_id"

        enum object_association: {
            ticket: "ticket"
        }

        def self.association_class_name(association_name)
            case association_name
            when "ticket"
                return "CloudHelp::Ticket"
            else
                return nil
            end
        end

=begin
@return [Array] An array of details of the assocciation. 
@description Depending on the *association_name*, returns extra information needed. For example, 
    a specific workflow can be associated to a project based on the project type,
    rather than the table as a whole, if there are no association details, an empty array is returned
=end
        def self.object_association_details(association_name)
            case association_name
            when "ticket"
                return [
                    {
                        name: "ticket_type",
                        type: "foreign_key",
                        class: "CloudHelp::Catalog::TicketType",
                        key: :cloud_help_catalog_ticket_types_id,
                        identifier: :name
                    }
                ]
            else
                return []
            end
        end
    end
end
