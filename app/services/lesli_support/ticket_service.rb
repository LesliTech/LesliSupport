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

        def find(id: nil, uid: nil)
            scope  = current_user.account.support.tickets

            # Use a hash to filter out nil values and find the record
            params = { id: id, uid: uid }.compact

            # Search and assign the resource if search params exist
            super(scope.find_by(params)) if params.any?
        end

        def index

            return current_user.account.support.tickets.left_joins(
                :user, 
                :owner, 
                :priority
            ).select(
                :id,
                :uid,
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
            ticket.owner = current_user
            ticket.user = current_user

            Ticket.transaction do
                ticket.save!
                ticket.record_activity!(
                    actor: current_user,
                    code: :ticket_created,
                    description: "Ticket created",
                    metadata: {
                        from: nil,
                        to: ticket_snapshot(ticket)
                    }
                )
            end

            self.resource = ticket
            self
        rescue ActiveRecord::RecordInvalid => exception
            self.resource = ticket
            error(exception.record.errors.full_messages.to_sentence)
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
            Ticket.transaction do
                resource.update!(params)
                record_update_activities
            end

            self
        rescue ActiveRecord::RecordInvalid => exception
            message = exception.record.errors.full_messages.to_sentence
            resource.reload if resource.persisted?
            error(message)
            self
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

        private

        def record_update_activities
            record_relation_change(:owner, :owner_changed, "Ticket owner")
            record_relation_change(:type, :type_changed, "Ticket type")
            record_relation_change(:category, :category_changed, "Ticket category")
            record_relation_change(:priority, :priority_changed, "Ticket priority")
        end

        def record_relation_change(association_name, code, label)
            change = resource.saved_changes["#{association_name}_id"]
            return unless change

            model = resource.class.reflect_on_association(association_name).klass
            metadata = {
                from: relation_snapshot(model, change.first),
                to: relation_snapshot(model, change.last)
            }

            resource.record_activity!(
                actor: current_user,
                code: code,
                description: relation_change_description(label, metadata),
                metadata: metadata
            )
        end

        def relation_snapshot(model, id)
            return if id.nil?

            record = model.find_by(id: id)
            {
                id: id,
                name: record&.name
            }
        end

        def relation_change_description(label, metadata)
            return "#{label} removed" unless metadata[:to]
            return "#{label} set to #{snapshot_name(metadata[:to])}" unless metadata[:from]

            "#{label} changed from #{snapshot_name(metadata[:from])} " \
                "to #{snapshot_name(metadata[:to])}"
        end

        def snapshot_name(snapshot)
            snapshot[:name].presence || "##{snapshot[:id]}"
        end

        def ticket_snapshot(ticket)
            {
                id: ticket.id,
                uid: ticket.uid,
                subject: ticket.subject
            }
        end
    end
end
