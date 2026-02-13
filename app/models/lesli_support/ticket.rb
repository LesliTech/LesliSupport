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
        belongs_to :account
        belongs_to :owner, class_name: "Lesli::User"
        belongs_to :user, class_name: "Lesli::User"

        belongs_to :type, optional: true, class_name: "Catalog::Item"
        belongs_to :category, optional: true, class_name: "Catalog::Item"
        belongs_to :priority, optional: true, class_name: "Catalog::Item"

        has_many :activities
        has_many :discussions

        before_create :before_create_ticket
        after_save :after_save_ticket

        private

        def before_create_ticket
            prefix = Lesli.config.support.dig(:prefix)
            self.subject = self.subject.titleize
            self.uid ||= loop do
                candidate = generate_resource_uid(prefix:prefix)
                break candidate unless Ticket.exists?(uid: candidate)
            end
        end

        def after_save_ticket
            if self.saved_change_to_owner_id?
                self.activities.create(
                    description: "Agent assigned #{self.owner.name}",
                    activity_code: :owner_id,
                    metadata: { owner_id: self.owner.id, icon: 'favorite' }
                )
            end 

            if self.saved_change_to_type_id?
                self.activities.create(
                    description: "Ticket type updated to #{self.type.name}",
                    activity_code: :type_id,
                    metadata: { type_id: self.type.id, icon: 'star' }
                )
            end 

            if self.saved_change_to_category_id?
                self.activities.create(
                    description: "Ticket category updated to #{self.category.name}",
                    activity_code: :category_id,
                    metadata: { category_id: self.category.id, icon: 'search' }
                )
            end 

            if self.saved_change_to_priority_id?
                self.activities.create(
                    description: "Ticket priority updated to #{self.priority.name}",
                    activity_code: :priority_id,
                    metadata: { priority_id: self.priority.id, icon: 'sunny' }
                )
            end 
        end
    end
end
