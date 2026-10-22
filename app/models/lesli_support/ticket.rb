=begin

Lesli

Copyright (c) 2026, Lesli Technologies, S. A.

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
    class Ticket < Lesli::ApplicationLesliRecord
        belongs_to :account, class_name: "LesliSupport::Account"
        belongs_to :owner, class_name: "Lesli::User"
        belongs_to :user, class_name: "Lesli::User"

        # Catalogs
        belongs_to :type, optional: true, class_name: "Catalog::Item"
        belongs_to :category, optional: true, class_name: "Catalog::Item"
        belongs_to :priority, optional: true, class_name: "Catalog::Item"

        # Items
        include Lesli::Items::Tasks
        include Lesli::Items::Activities
        include Lesli::Items::Discussions
        include Lesli::Items::Attachments

        # include Lesli::Items::Subscribers

        # Hooks
        before_create :before_create_ticket

        # Shared items belong to the same engine account as the ticket.
        def lesli_item_account
            account
        end

        def lesli_item_accessible_by?(user)
            user.present? && account.account == user.account
        end

        private

        def before_create_ticket
            prefix = Lesli.config.support.dig(:prefix)
            self.subject = self.subject.titleize
            self.uid ||= loop do
                candidate = generate_resource_uid(prefix:prefix)
                break candidate unless Ticket.exists?(uid: candidate)
            end
        end

    end
end
