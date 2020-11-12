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
    class Dashboard::Component < CloudObject::Dashboard::Component
        belongs_to :dashboard, inverse_of: :components, class_name: "Dashboard", foreign_key: "cloud_help_dashboards_id"

        enum component_ids: {
            new_tickets: "new_tickets",
            my_tickets: "my_tickets"
        }

        def self.configuration_options
            list_configuration = [
                { column: "query_configuration", group: "pagination", name: "per_page", type: "Integer" }
            ]
            
            {
                new_tickets: list_configuration,
                my_tickets: list_configuration
            }
        end

        def new_tickets(current_user, query)
            configuration = parse_configuration()
            unless current_user.has_privileges?(["cloud_help/tickets"], ["index"])
                return nil
            end

            data = Ticket
            .joins(:detail)
            .joins(:priority)
            .order("cloud_help_tickets.created_at desc")
            .limit(configuration[:query][:pagination]["per_page"] || query[:pagination][:perPage])
            .select(
                "cloud_help_tickets.created_at",
                "cloud_help_tickets.id",
                "cloud_help_ticket_details.subject",
                "cloud_help_catalog_ticket_priorities.name as priority_name",
                "cloud_help_catalog_ticket_priorities.weight as priority_weight",
                "CONCAT('/help/tickets/', cloud_help_tickets.id) as url"
            )

            data.map do |ticket|
                ticket_attributes =ticket.attributes
                ticket_attributes["created_at"] = LC::Date.to_string_datetime(ticket.created_at)
                ticket_attributes
            end
        end
    end
end
