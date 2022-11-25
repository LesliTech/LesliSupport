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
        include ActiveModel::Dirty

        belongs_to  :account, class_name: "CloudHelp::Account", foreign_key: "cloud_help_accounts_id"
        has_many    :tickets, class_name: "CloudHelp::Ticket",  foreign_key: "cloud_help_catalog_ticket_workspaces_id"

        validates :name, presence: true

        after_update :validate_default_record
        after_create :validate_default_record
        before_destroy :rollback_if_default

        def self.index(current_user, query)
            # get search string from query params
            search_string = query[:search].downcase.gsub(" ","%") unless query[:search].blank?

            # Executing the query
            workspaces = current_user.account.help.ticket_workspaces.select(:id, :name, :default, LC::Date2.new.db_timestamps)

            # We filter by a text string written by the user
            unless search_string.blank?
                workspaces = workspaces.where("
                        (CAST(id AS VARCHAR) SIMILAR TO :search_string)  OR
                        (LOWER(name) SIMILAR TO  :search_string)
                    ", search_string: "%#{sanitize_sql_like(search_string, " ")}%")
            end

            workspaces = workspaces.page(query[:pagination][:page])
            .per(query[:pagination][:perPage])
            .order("#{query[:pagination][:orderBy]} #{query[:pagination][:order]} NULLS LAST")

            workspaces
        end

        def show(current_user, query)
            ticket_attributes = self.attributes

            ticket_attributes["created_at"] = LC::Date.to_string_datetime(ticket_attributes["created_at"])
            ticket_attributes["updated_at"] = LC::Date.to_string_datetime(ticket_attributes["updated_at"])

            ticket_attributes
        end

        protected

        def validate_default_record
            if self.saved_changes["default"]
                # Default changed from false to true
                if self.saved_changes["default"][1]
                    self.account.ticket_workspaces.where("id != ?", id).where(default: true).update_all(default: false)
                # Default changed from true to false
                else
                    errors.add(:base, I18n.t("help.catalog/ticket_workspaces.messages_warning_default_workspace_must_exist"))
                    raise ActiveRecord::Rollback unless self.account.ticket_workspaces.where("id != ?", id).where(default: true).count > 0
                end
            end
        end

        def rollback_if_default
            if default
                errors.add(:base, I18n.t("help.catalog/ticket_workspaces.messages_warning_cannot_destroy_default"))
                raise ActiveRecord::Rollback
            end
        end
    end
end
