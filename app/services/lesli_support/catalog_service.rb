=begin

Lesli

Copyright (c) 2023, Lesli Technologies, S. A.

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program. If not, see http://www.gnu.org/licenses/.

Lesli · Ruby on Rails SaaS Development Framework.

Made with ♥ by https://www.lesli.tech
Building a better future, one line of code at a time.

@contact  hello@lesli.tech
@website  https://www.lesli.tech
@license  GPLv3 http://www.gnu.org/licenses/gpl-3.0.en.html

// · ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~
// · 
=end

module LesliSupport
    class CatalogService < Lesli::ApplicationLesliService

        def find ticket_id
            super(current_user.account.help.tickets.find_by(id: ticket_id))
        end

        def index

            return current_user.account.support.tickets.left_joins(
                :user, :creator
            ).select(
                :id,
                :subject,
                :deadline,
                :creator_id,
                :user_id,
                "CONCAT_WS(' ', lesli_users.first_name, lesli_users.last_name) as user_name",
                "CONCAT_WS(' ', creators_lesli_support_tickets.first_name, creators_lesli_support_tickets.last_name) as creator_name",
                "lesli_support_tickets.updated_at",
                "lesli_support_tickets.created_at"
            ).order(id: :desc)
            .page(query[:pagination][:page])
            .per(query[:pagination][:perPage])

            current_user.account.help.tickets.left_joins(
                :priority, 
                :type, 
                :workspace, 
                :category, 
                :status, 
                :assignments,
                :assigned,
                :user
            ).select(
                :id,
                :subject,
                :deadline,
                :assigned_id,
                :user_id,
                "CONCAT_WS(' ', users.first_name, users.last_name) as assigned_name",
                "CONCAT_WS(' ', users_cloud_help_tickets.first_name, users_cloud_help_tickets.last_name) as user_name",
                "cloud_help_tickets.updated_at",
                "cloud_help_tickets.created_at"
            )
        end

        def create(ticket_params)

            ticket = current_user.account.help.tickets.new(ticket_params)
            #ticket.source = Catalog::TicketSource.cloud_help_source(current_user.account.help)
            ticket.creator = current_user
            ticket.user = current_user

            unless ticket_params.dig(:started_at)
                #ticket.started_at = LC::Date2.new(Time.current).date.get
            end

            if ticket.save
                #Ticket.log_activity_create(current_user, ticket)
                #Ticket::Subscriber.add_subscriber(ticket, current_user, "discussion_created", "email")
                #Workflow::Action.execute_actions(current_user, ticket, {}, ticket.attributes)
                self.resource = ticket
            else
                pp ticket.errors.full_messages
                self.error(ticket.errors.full_messages.to_sentence)
            end

            self
        end

        def show()
            return current_user.account.help.tickets.left_joins(
                :user, :creator
            ).select(
                :id,
                :subject,
                :deadline,
                :creator_id,
                :user_id,
                "CONCAT_WS(' ', lesli_users.first_name, lesli_users.last_name) as user_name",
                "CONCAT_WS(' ', creators_lesli_support_tickets.first_name, creators_lesli_support_tickets.last_name) as creator_name",
                "lesli_support_tickets.updated_at",
                "lesli_support_tickets.created_at"
            ).where("lesli_support_tickets.id = ?", self.resource.id).first
        end

        def options() 
            catalogs = {}

            # Retrieve all root nodes (nodes with no parent)
            root_catalogs = current_user.account.support.catalogs
                .where(ancestry: nil)

            # Fetch all trees
            root_catalogs.each do |catalog|
                catalogs[catalog.name.downcase] = {
                    id: catalog.id,
                    name: catalog.name,
                    options: catalog.children
                }
            end

            catalogs
        end
    end
end
