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
    class Dashboard::Component < Shared::Dashboard::Component
        belongs_to :dashboard, inverse_of: :components, class_name: "Dashboard", foreign_key: "cloud_help_dashboards_id"

        enum component_ids: {
            new_tickets: "new_tickets",
            my_tickets: "my_tickets",
            unassigned_tickets: "unassigned_tickets",
            tickets_by_type: "tickets_by_type",
            tickets_by_category: "tickets_by_category",
            hours_worked: "hours_worked"
        }

        def self.configuration_options
            chart_configuration = [
                { column: "query_configuration", group: "filters", name: "only_main_user", type: "Boolean" },
                { column: "custom_configuration", group: "arrangement", name: "range_before", type: "Integer"},
                { column: "custom_configuration", group: "arrangement", name: "range_after", type: "Integer"}
            ]

            list_configuration = [
                { column: "query_configuration", group: "pagination", name: "per_page", type: "Integer" }
            ]
            
            {
                new_tickets: list_configuration,
                my_tickets: list_configuration,
                unassigned_tickets: list_configuration,
                hours_worked: chart_configuration,
                tickets_by_type: [],
                tickets_by_category: []
            }
        end

        def hours_worked(current_user, query)
            configuration = parse_configuration()
            unless current_user.has_privileges?(["cloud_help/tickets"], ["index"])
                return nil
            end

            datetime_start = LC::Date.now.months_ago((configuration[:custom][:arrangement]["range_before"].to_i || 4)).beginning_of_month
            datetime_end = LC::Date.now.end_of_month + (configuration[:custom][:arrangement]["range_after"].to_i || 0).months

            data = current_user.account.help.tickets
            .joins(:type)
            .where("cloud_help_tickets.created_at between ? and ?", datetime_start, datetime_end)

            if configuration[:query][:filters]["only_main_user"]
                data = data
                .left_outer_joins(:assignments)
                .where("cloud_help_ticket_assignments.users_id = ?", current_user.id)
            end

            data = data.select(
                "SUM(cloud_help_tickets.hours_worked) as hours_worked",
                "cloud_help_tickets.cloud_help_catalog_ticket_types_id",
                "cloud_help_catalog_ticket_types.name as type",
                LC::Date.db_to_char_custom("cloud_help_tickets.created_at", include_alias: true, alias_name: "date", db_format: "yyyy-mm")
            )
            .group(
                "date",
                "cloud_help_catalog_ticket_types.name", 
                "cloud_help_tickets.cloud_help_catalog_ticket_types_id"
            ).map do |ticket|
                ticket_attributes = ticket.attributes
                
                {
                    hours_worked: ticket_attributes["hours_worked"],
                    type: ticket_attributes["type"],
                    date: ticket_attributes["date"]
                }
            end

            group_by_month(datetime_start, datetime_end, data)
        end

        def new_tickets(current_user, query)
            configuration = parse_configuration()
            unless current_user.has_privileges?(["cloud_help/tickets"], ["index"])
                return nil
            end

            data = Ticket
            .joins(:priority)
            .joins(:status)
            .order("cloud_help_tickets.created_at desc")
            .where("cloud_help_workflow_statuses.status_type not in (?)", ['completed_successfully', 'completed_unsuccessfully'])
            .limit(configuration[:query][:pagination]["per_page"] || query[:pagination][:perPage])
            .select(
                "cloud_help_tickets.created_at",
                "cloud_help_tickets.id",
                "cloud_help_tickets.subject",
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

        def my_tickets(current_user, query)
            configuration = parse_configuration()
            unless current_user.has_privileges?(["cloud_help/tickets"], ["index"])
                return nil
            end

            data = Ticket
            .joins(:status)
            .joins("LEFT JOIN cloud_help_ticket_assignments CHTA ON CHTA.cloud_help_tickets_id = cloud_help_tickets.id AND CHTA.deleted_at IS NULL")
            .where("cloud_help_tickets.users_id = ? OR CHTA.users_id = ?", current_user.id, current_user.id)
            .where("cloud_help_workflow_statuses.status_type not in (?)", ['completed_successfully', 'completed_unsuccessfully'])
            .order("cloud_help_tickets.subject asc")
            .limit(configuration[:query][:pagination]["per_page"] || query[:pagination][:perPage])
            .select(
                "cloud_help_tickets.id",
                "cloud_help_tickets.subject",
                "cloud_help_tickets.deadline",
                "cloud_help_workflow_statuses.name as status_name",
                "CONCAT('/help/tickets/', cloud_help_tickets.id) as url"
            )

            data.map do |ticket|
                ticket_attributes = ticket.attributes
                ticket_attributes["deadline_raw"] = ticket.deadline
                ticket_attributes["deadline"] = LC::Date.to_string(ticket.deadline)
                ticket_attributes
            end
        end

        def unassigned_tickets(current_user, query)
            configuration = parse_configuration()
            unless current_user.has_privileges?(["cloud_help/tickets"], ["index"])
                return nil
            end

            data = Ticket.joins(:status)
            .joins(:priority)
            .joins("LEFT JOIN cloud_help_ticket_assignments CHTA on CHTA.cloud_help_tickets_id = cloud_help_tickets.id AND CHTA.deleted_at is NULL")
            .order("cloud_help_tickets.created_at asc")
            .where("cloud_help_workflow_statuses.status_type not in (?)", ['completed_successfully', 'completed_unsuccessfully'])
            .where("CHTA.id is ?", nil)
            .select(
                "cloud_help_tickets.deadline",
                "cloud_help_tickets.id",
                "cloud_help_tickets.subject",
                "cloud_help_catalog_ticket_priorities.name as priority_name",
                "cloud_help_catalog_ticket_priorities.weight as priority_weight",
                "CONCAT('/help/tickets/', cloud_help_tickets.id) as url"
            )

            data.map do |ticket|
                ticket_attributes = ticket.attributes
                ticket_attributes["deadline_raw"] = ticket.deadline
                ticket_attributes["deadline"] = LC::Date.to_string(ticket.deadline)
                ticket_attributes
            end
        end

        def tickets_by_type(current_user, query)
            configuration = parse_configuration()
            unless current_user.has_privileges?(["cloud_help/tickets"], ["index"])
                return nil
            end

            Catalog::TicketType.joins(
                "LEFT JOIN cloud_help_tickets CHT on CHT.cloud_help_catalog_ticket_types_id = cloud_help_catalog_ticket_types.id AND CHT.deleted_at IS NULL"
            ).where(
                "CHT.created_at >= ?", LC::Date.beginning_of_month()
            ).group(:type_name)
            .select(
                "COUNT(CHT.id) as tickets_count",
                "cloud_help_catalog_ticket_types.name as type_name"
            )
        end

        def tickets_by_category(current_user, query)
            configuration = parse_configuration()
            unless current_user.has_privileges?(["cloud_help/tickets"], ["index"])
                return nil
            end

            Catalog::TicketCategory.joins(
                "LEFT JOIN cloud_help_tickets CHT on CHT.cloud_help_catalog_ticket_categories_id = cloud_help_catalog_ticket_categories.id AND CHT.deleted_at IS NULL"
            ).where(
                "CHT.created_at >= ?", LC::Date.beginning_of_month()
            ).group(:category_name)
            .select(
                "COUNT(CHT.id) as tickets_count",
                "cloud_help_catalog_ticket_categories.name as category_name"
            )
        end

        protected
        
        def group_by_month(datetime_start, datetime_end, data)
            parsed_data = []
            date = datetime_start
            while date <= datetime_end
                month = LC::Date.to_string_datetime_words(date, "%Y-%m")
                tickets_by_date = data.find_all do |ticket| 
                    ticket[:date] == month
                end

                parsed_data.push(tickets_by_date)
                date += 1.month
            end

            parsed_data
        end
    end
end
