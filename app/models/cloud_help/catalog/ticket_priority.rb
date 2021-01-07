module CloudHelp
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
    class Catalog::TicketPriority < ApplicationLesliRecord

        belongs_to  :account, class_name: "CloudHelp::Account", foreign_key: "cloud_help_accounts_id"
        has_many    :tickets, class_name: "CloudHelp::Ticket",  foreign_key: "cloud_help_catalog_ticket_priorities_id"

        validates :name, presence: true
        validates :weight, presence: true

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
            ticket_priorities = current_user.account.help.ticket_priorities

            # We apply the previous filters in the main query
            unless filters_query.empty?
                ticket_priorities = ticket_priorities.where(filters_query.join(' and '))
            end

            response = {}
            # total count
            response[:total_count] = ticket_priorities.length if filters["get_total_count"]

            # Adding pagination to ticket_priorities
            pagination = query[:pagination]
            ticket_priorities = ticket_priorities.page(
                pagination[:page]
            ).per(
                pagination[:perPage]
            ).order(
                "#{pagination[:orderColumn]} #{pagination[:order]} NULLS LAST"
            )

            # We format the response
            response[:ticket_priorities] = ticket_priorities.map do |ticket_priority|
                ticket_priority_attributes = ticket_priority.attributes
                ticket_priority_attributes["created_at"] = LC::Date.to_string_datetime(ticket_priority_attributes["created_at"])

                ticket_priority_attributes
            end
            
            response
        end

        def show
            data = attributes
            data["created_at"] = LC::Date.to_string_datetime(data["created_at"])
            data["updated_at"] = LC::Date.to_string_datetime(data["updated_at"])

            data
        end
        
    end
end
