=begin

Copyright (c) 2022, all rights reserved.

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
    class Catalog::TicketPriority < ApplicationLesliRecord
        belongs_to  :account, class_name: "CloudHelp::Account", foreign_key: "cloud_help_accounts_id"
        has_many    :tickets, class_name: "CloudHelp::Ticket",  foreign_key: "cloud_help_catalog_ticket_priorities_id"

        validates :name, presence: true
        validates :weight, presence: true

        def self.index(current_user, query)

            # get search string from query params
            search_string = query[:search].downcase.gsub(" ","%") unless query[:search].blank?
            
            # Executing the query
            ticket_priorities = current_user.account.help.ticket_priorities

            # We filter by a text string written by the user
            unless search_string.blank?
                ticket_priorities = ticket_priorities.where("
                        (CAST(id AS VARCHAR) SIMILAR TO :search_string)  OR
                        (LOWER(name) SIMILAR TO  :search_string)
                    ", search_string: "%#{sanitize_sql_like(search_string, " ")}%")
            end
            
            # Adding pagination to ticket_priorities
            ticket_priorities = ticket_priorities.page(query[:pagination][:page])
            .per(query[:pagination][:perPage])
            .order("#{query[:pagination][:orderBy]} #{query[:pagination][:order]}")

            # Selecting columns 
            ticket_priorities = ticket_priorities.select(
                :id,
                :name,
                :weight,
                :days_to_deadline,
                :cloud_help_accounts_id,
                LC::Date2.new.date.db_column("created_at"),
                LC::Date2.new.date.db_column("updated_at"),
                LC::Date2.new.date.db_column("deleted_at")
            )
            
            ticket_priorities
        end

        def show
            data = attributes
            data["created_at"] = LC::Date.to_string_datetime(data["created_at"])
            data["updated_at"] = LC::Date.to_string_datetime(data["updated_at"])

            data
        end
        
    end
end
