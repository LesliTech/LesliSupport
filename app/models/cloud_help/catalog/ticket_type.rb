module CloudHelp
=begin

Lesli

Copyright (c) 2020, Lesli Technologies, S. A.

All the information provided by this website is protected by laws of Guatemala related 
to industrial property, intellectual property, copyright and relative international laws. 
Lesli Technologies, S. A. is the exclusive owner of all intellectual or industrial property
rights of the code, texts, trade mark, design, pictures and any other information.
Without the written permission of Lesli Technologies, S. A., any replication, modification,
transmission, publication is strictly forbidden.
For more information read the license file including with this software.

LesliCloud - Your Smart Business Assistant

Powered by https://www.lesli.tech
Building a better future, one line of code at a time.

@author   Carlos Hermosilla
@license  Propietary - all rights reserved.
@version  0.1.0-alpha
@description Model for ticket types

=end
    class Catalog::TicketType < ApplicationLesliRecord
        belongs_to  :account, class_name: "CloudHelp::Account",     foreign_key: "cloud_help_accounts_id"
        has_many    :tickets, class_name: "CloudHelp::Ticket",      foreign_key: "cloud_help_catalog_ticket_types_id"

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
            ticket_types = current_user.account.help.ticket_types

            # We apply the previous filters in the main query
            unless filters_query.empty?
                ticket_types = ticket_types.where(filters_query.join(' and '))
            end

            response = {}
            # total count
            response[:total_count] = ticket_types.length if filters["get_total_count"]

            # Adding pagination to ticket_types
            pagination = query[:pagination]
            ticket_types = ticket_types.page(
                pagination[:page]
            ).per(
                pagination[:perPage]
            ).order(
                "#{pagination[:orderColumn]} #{pagination[:order]} NULLS LAST"
            )

            # We format the response
            response[:ticket_types] = ticket_types.map do |ticket_type|
                ticket_type_attributes = ticket_type.attributes
                ticket_type_attributes["created_at"] = LC::Date.to_string_datetime(ticket_type_attributes["created_at"])

                ticket_type_attributes
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
    