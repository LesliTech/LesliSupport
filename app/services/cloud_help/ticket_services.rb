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
    class TicketServices

        def self.create(current_user, ticket_params)

            ticket = current_user.account.help.tickets.new(ticket_params)
            ticket.source = Catalog::TicketSource.cloud_help_source(current_user.account.help)
            ticket.user_creator = current_user

            if ticket.save
                Ticket.log_activity_create(current_user, ticket)
                Ticket::Subscriber.add_subscriber(ticket, current_user, "discussion_created", "email")
                Workflow::Action.execute_actions(current_user, ticket, {}, ticket.attributes)

                return LC::Response.service(true, ticket)
            else
                return LC::Response.service(false, ticket.errors)
            end
        end

        def self.update(current_user, ticket, ticket_params)
            old_attributes = ticket.attributes

            if ticket.update(ticket_params)
                new_attributes = ticket.attributes
                Ticket.log_activity_update(current_user, ticket, old_attributes, new_attributes)
                Workflow::Action.execute_actions(current_user, ticket, old_attributes, new_attributes)

                return LC::Response.service(true, ticket)
            else
                return LC::Response.service(false, ticket)
            end
        end

        def self.destroy(current_user, ticket)
            if ticket.destroy
                Ticket.log_activity_destroy(current_user, ticket)
                return LC::Response.service(true)
            else
                return LC::Response.service(false, ticket)
            end
        end

        def self.show(current_user, ticket, query)

            data = Ticket.joins(
                "left join cloud_help_catalog_ticket_priorities chctp on cloud_help_tickets.cloud_help_catalog_ticket_priorities_id = chctp.id"
            ).joins(
                "left join cloud_help_catalog_ticket_types chctt on cloud_help_tickets.cloud_help_catalog_ticket_types_id = chctt.id"
            ).joins(
                "left join cloud_help_catalog_ticket_categories chctc on cloud_help_tickets.cloud_help_catalog_ticket_categories_id = chctc.id"
            ).joins(
                "left join cloud_help_catalog_ticket_workspaces chctw on cloud_help_tickets.cloud_help_catalog_ticket_workspaces_id = chctw.id"
            ).joins(
                "left join cloud_help_workflow_statuses chws on cloud_help_tickets.cloud_help_workflow_statuses_id = chws.id"
            ).joins(
                "left join cloud_help_workflows chw on chws.cloud_help_workflows_id = chw.id"
            ).joins(
                "left join cloud_help_ticket_assignments chta on cloud_help_tickets.id = chta.cloud_help_tickets_id and chta.deleted_at is null"
            ).joins(
                "left join users u on cloud_help_tickets.users_id = u.id"
            ).joins(
                "left join user_details ud on u.id = ud.users_id"
            ).select(
                "cloud_help_tickets.id as id",                      "cloud_help_tickets.created_at as created_at",
                "chctp.name as priority",                           "chctt.name as type",
                "chws.name as status",                              "chctp.id as cloud_help_catalog_ticket_priorities_id",
                "chctt.id as cloud_help_catalog_ticket_types_id",   "chctc.id as cloud_help_catalog_ticket_categories_id",
                "chws.id as cloud_help_workflow_statuses_id",       "chctp.weight as priority_weight",
                "chws.status_type as status_type",                  "chw.id as cloud_help_workflows_id",
                "chws.number as status_number",                     "subject",
                "description",                                      "deadline",
                "tags",                                             "hours_worked",
                "reference_url",                                    "chctw.name as workspace",
                "chctw.id as cloud_help_catalog_ticket_workspaces_id",
                " coalesce(nullif(concat(ud.first_name, ' ', ud.last_name), ''), u.email) as user_creator_name"
            )
            .where("cloud_help_tickets.id = #{ticket.id}").first.attributes

            data[:category] = ticket.category.full_path if ticket.category
            data[:assignment_attributes] = ticket.assignments_info
            data[:editable] = ticket.is_editable_by?(current_user)
            data[:sla] = ticket.sla.show(current_user, query) if ticket.sla
            data[:files_count] = ticket.files.count
            data[:subscribed] = (ticket.subscribers.where(user_creator: current_user).count > 0)

            return LC::Response.service(true, data)
        end

        def self.index(current_user, query, params)

            # get search string from query params
            search_string = query[:search].downcase.gsub(" ","%") unless query[:search].blank?

            # Parsing filters
            filters = params[:f]
            filters_query = []

            unless filters.blank?
                # We filter by search_type, available search_types are 'own' and 'active'
                if filters["search_type"] && current_user.account.help.workflows.count > 0
                    filters_query.push("(cloud_help_workflow_statuses.status_type != 'completed_unsuccessfully' AND cloud_help_workflow_statuses.status_type != 'completed_successfully')") if filters["search_type"].eql? "active"
                    filters_query.push("(cloud_help_workflow_statuses.status_type = 'completed_unsuccessfully' OR cloud_help_workflow_statuses.status_type = 'completed_successfully')") if filters["search_type"].eql? "inactive"
                end

                # We filter by user_type, which can be 'own' or null
                if filters["user_type"].eql? "own"
                    filters_query.push("(cloud_help_tickets.users_id = #{current_user.id} OR cloud_help_ticket_assignments.users_id = #{current_user.id})")
                end

                if filters["workspace_id"]
                    filters_query.push("(cloud_help_tickets.cloud_help_catalog_ticket_workspaces_id = #{filters["workspace_id"]})")
                end

                # We filter by a text string written by the user
                if filters["query"] && !filters["query"].empty?
                    query_words = filters["query"].split(" ")
                    query_words.each do |query_word|
                        query_word = query_word.strip.downcase

                        # first customer
                        filters_query.push("(
                            (CAST(cloud_help_tickets.id AS VARCHAR) = '#{query_word}') OR
                            (LOWER(subject) SIMILAR TO '%#{query_word}%') OR
                            (LOWER(cloud_help_catalog_ticket_categories.name) SIMILAR TO '%#{query_word}%') OR
                            (LOWER(cloud_help_catalog_ticket_types.name) SIMILAR TO '%#{query_word}%') OR
                            (LOWER(cloud_help_catalog_ticket_priorities.name) SIMILAR TO '%#{query_word}%') OR
                            (LOWER(tags) SIMILAR TO '%#{query_word}%')
                        )")
                    end
                end

                # We filter by statuses
                if filters["statuses"] && !filters["statuses"].empty?
                    statuses_query = filters["statuses"].map do |status|
                        "cloud_help_workflow_statuses.id = '#{status["id"]}'"
                    end
                    filters_query.push("(#{statuses_query.join(' or ')})")
                end
            end

            # Executing the query
            tickets = current_user.account.help.tickets.eager_load(
                :priority, 
                :type, 
                :workspace, 
                :category, 
                :status, 
                :assignments, 
                user_creator: :detail
            ).select(
                :id,
                :subject,
                :deadline,
                :users_id,
                :user_main_id,
                :cloud_help_workflow_statuses_id,
                "cloud_help_catalog_ticket_priorities.name as priority",
                "cloud_help_catalog_ticket_priorities.id as cloud_help_catalog_ticket_priorities_id",
                "cloud_help_catalog_ticket_priorities.weight as priority_weight",
                "cloud_help_catalog_ticket_types.name as type",
                "cloud_help_catalog_ticket_workspaces.name as workspace",
                "cloud_help_catalog_ticket_types.id as cloud_help_catalog_ticket_types_id",
                "cloud_help_catalog_ticket_categories.name as category",
                "cloud_help_workflow_statuses.status_type as status_type",
                "cloud_help_workflow_statuses.name as status_name",
                "users.id as user_creator_id",
                "CONCAT(user_details.first_name, ' ', user_details.last_name) as user_creator",
                "cloud_help_catalog_ticket_categories.id as cloud_help_catalog_ticket_categories_id",
                :created_at,
                :cloud_help_catalog_ticket_workspaces_id
            )

            # We apply the previous filters in the main query
            unless filters_query.empty?
                tickets = tickets.where(filters_query.join(" AND "))
            end

            unless search_string.blank?
                tickets = tickets.where("
                        (CAST(cloud_help_tickets.id AS VARCHAR) SIMILAR TO :search_string)  OR
                        (LOWER(subject) SIMILAR TO  :search_string) OR
                        (LOWER(cloud_help_catalog_ticket_categories.name)   SIMILAR TO :search_string) OR
                        (LOWER(cloud_help_catalog_ticket_types.name)        SIMILAR TO  :search_string) OR
                        (LOWER(cloud_help_catalog_ticket_priorities.name)        SIMILAR TO  :search_string) OR
                        (LOWER(user_details.first_name)       SIMILAR TO  :search_string) OR
                        (LOWER(user_details.last_name)       SIMILAR TO  :search_string) OR
                        (LOWER(tags)      SIMILAR TO  :search_string)
                    ", search_string: "%#{ActiveRecord::Base.sanitize_sql_like(search_string, " ")}%")
            end

            tickets = tickets.order("#{query[:pagination][:orderBy]} #{query[:pagination][:order]}")

            tickets = tickets.map do |ticket|
                ticket_attributes = ticket.attributes
                ticket_attributes["editable"] = ticket.is_editable_by?(current_user)
                ticket_attributes["deadline_text"] = LC::Date.to_string(ticket_attributes["deadline"])
                ticket_attributes["created_at"] = LC::Date.to_string_datetime(ticket_attributes["created_at"])
                ticket_attributes["assignment_type"] = Ticket::Assignment.assignment_types.key(ticket[:assignment_type])

                if ticket[:cloud_help_catalog_ticket_categories_id]
                    ticket_attributes["category"] = Catalog::TicketCategory.with_deleted.find(ticket[:cloud_help_catalog_ticket_categories_id]).full_path
                end

                if ticket.assignments.length > 0
                    users = []
                    ticket.assignments.order(id: :asc).each do |assigment|
                        users.push(assigment.user.full_name)
                    end
                    ticket_attributes["assignables"] = users
                end
                ticket_attributes
            end

            LC::Response.service(true, tickets)
        end

        def self.count(current_user)
            tickets_count = current_user.account.help.tickets
            .joins(:status)
            .joins("
                left join cloud_help_ticket_assignments chta on 
                    chta.deleted_at is null and 
                    chta.cloud_help_tickets_id = cloud_help_tickets.id
            ").joins("
                left join users on 
                    cloud_help_tickets.users_id = users.id and
                    users.id = #{current_user.id}
            ").where("cloud_help_workflow_statuses.status_type not in (?)", ["completed_successfully", "completed_unsuccessfully"])
            .where("cloud_help_tickets.users_id = ? or chta.users_id = ? ", current_user.id, current_user.id)
            .count

            return LC::Response.service(true, tickets_count)
        end

    end
end
