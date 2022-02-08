=begin
Copyright (c) 2021, all rights reserved.

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
    class Catalog::TicketWorkspace < ApplicationLesliRecord
        belongs_to  :account, class_name: "CloudHelp::Account", foreign_key: "cloud_help_accounts_id"
        has_many    :tickets, class_name: "CloudHelp::Ticket",  foreign_key: "cloud_help_catalog_ticket_workspaces_id"

        validates :name, presence: true

        def self.index(current_user, query)
            # Parsing filters
            filters = query[:filters]
            filters_query = []

            # We filter by a text string written by the user
            if filters["query"] && !filters["query"].empty?
                query_words = filters["query"].split(" ")
                query_words.each do |query_word|
                    query_word = query_word.strip.downcase

                    # first customer
                    filters_query.push("(LOWER(name) SIMILAR TO '%#{query_word}%')")
                end
            end

            # Executing the query
            workspaces = current_user.account.help.ticket_workspaces.select(:id, :name, :default, LC::Date2.new.db_timestamps)

            # We apply the previous filters in the main query
            unless filters_query.empty?
                workspaces = workspaces.where(filters_query.join(" AND "))
            end

            workspaces = workspaces.page(
                query[:pagination][:page]
            ).per(
                query[:pagination][:perPage]
            ).order(
                "#{query[:pagination][:orderBy]} #{query[:pagination][:order]} NULLS LAST"
            )

            workspaces
        end

        def show(current_user, query)
            self
        end
    end
end
