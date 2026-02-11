=begin

Lesli

Copyright (c) 2025, Lesli Technologies, S. A.

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

Made with ♥ by LesliTech
Building a better future, one line of code at a time.

@contact  hello@lesli.tech
@website  https://www.lesli.tech
@license  GPLv3 http://www.gnu.org/licenses/gpl-3.0.en.html

// · ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~
// · 
=end

module LesliSupport
    class TicketService < Lesli::ApplicationLesliService

        def find ticket_id
            super(current_user.account.support.tickets.find_by(id: ticket_id))
        end

        def index

            return current_user.account.support.tickets.left_joins(
                :user, 
                :owner, 
                :priority
            ).select(
                :id,
                :number,
                :subject,
                Date2.new.db_column(:deadline_at),
                "CONCAT_WS(' ', lesli_users.first_name, lesli_users.last_name) as user_name",
                "CONCAT_WS(' ', owners_lesli_support_tickets.first_name, owners_lesli_support_tickets.last_name) as agent_name",
                "lesli_support_catalog_items.name as priority_name"
            ).order(id: :desc)
            .page(query[:pagination][:page])
            .per(query[:pagination][:perPage])
        end

        def create(ticket_params)

            ticket = current_user.account.support.tickets.new(ticket_params)
            #ticket.source = Catalog::TicketSource.cloud_help_source(current_user.account.help)
            ticket.agent = current_user
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
            return current_user.account.support.tickets.left_joins(
                :user, :owner
            # ).select(
            #     :id,
            #     :subject,
            #     :description,
                # :reference_url,
                # :deadline,
                # :started_at,
                # :completed_at,
                # :hours_worked,
                # :creator_id,
                # :user_id,
                # :catalog_workspace_id, 
                # :catalog_type_id,
                # :catalog_category_id,
                # :catalog_priority_id,
                # "CONCAT_WS(' ', lesli_users.first_name, lesli_users.last_name) as user_name",
                # "CONCAT_WS(' ', creators_lesli_support_tickets.first_name, creators_lesli_support_tickets.last_name) as creator_name",
                # "lesli_support_tickets.updated_at",
                # "lesli_support_tickets.created_at"
            ).where("lesli_support_tickets.id = ?", self.resource.id).first
        end

        def update(params)
            self.resource.update(params)
        end 

        def with_deadline()
            current_user.account.support.tickets
            #.joins("left join cloud_help_ticket_assignments chta on chta.cloud_help_tickets_id = cloud_help_tickets.id and chta.users_id = #{current_user.id}")
            .select(:id, :subject, :description, :deadline)
            .where.not(:deadline => nil)
            #.where("cloud_help_tickets.deadline >= ?", query[:filters][:start_date])
            #.where("cloud_help_tickets.deadline <= ? ", query[:filters][:end_date])
            #.where("cloud_help_tickets.users_id = ? or cloud_help_tickets.user_main_id = ? or chta.users_id = ?", current_user.id, current_user.id, current_user.id)
            .order(:deadline)
        end
    end
end
