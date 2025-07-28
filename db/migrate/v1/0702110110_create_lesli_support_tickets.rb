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

class CreateLesliSupportTickets < ActiveRecord::Migration[6.0]
    def change
        create_table :lesli_support_tickets do |t|
            t.string  :subject 
            t.text    :description
            
            t.string  :tags
            t.decimal :hours_worked
            t.string  :reference_url

            t.datetime :deadline
            t.datetime :started_at
            t.datetime :completed_at

            t.datetime :deleted_at, index: true
            t.timestamps
        end

        add_reference(:lesli_support_tickets, :sla,      foreign_key: { to_table: :lesli_support_slas })
        add_reference(:lesli_support_tickets, :workspace,foreign_key: { to_table: :lesli_support_catalogs })
        add_reference(:lesli_support_tickets, :type,     foreign_key: { to_table: :lesli_support_catalog_items })
        add_reference(:lesli_support_tickets, :category, foreign_key: { to_table: :lesli_support_catalog_items })
        add_reference(:lesli_support_tickets, :priority, foreign_key: { to_table: :lesli_support_catalog_items })

        add_reference(:lesli_support_tickets, :user,    foreign_key: { to_table: :lesli_users })
        add_reference(:lesli_support_tickets, :agent,   foreign_key: { to_table: :lesli_users })
        add_reference(:lesli_support_tickets, :account, foreign_key: { to_table: :lesli_support_accounts })

        create_table_lesli_item_actions_10(:lesli_support_tickets)
        create_table_lesli_item_activities_10(:lesli_support_tickets)
        create_table_lesli_item_discussions_10(:lesli_support_tickets)
        create_table_lesli_item_subscribers_10(:lesli_support_tickets)
        create_table_lesli_item_attachments_10(:lesli_support_tickets)
        create_table_lesli_item_versions_10(:lesli_support_tickets)
    end
end
