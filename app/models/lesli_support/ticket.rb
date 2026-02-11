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

        def before_create_ticket
            self.subject = self.subject.titleize
            self.number ||= loop do
                candidate = generate_ticket_number
                break candidate unless Ticket.exists?(number: candidate)
            end
        end

        def generate_ticket_number
            prefix = Lesli.config.support.dig(:prefix)
            # No se usa 1 ni 0 para evitar ambigüedad
            # dicta números por teléfono los lee rápido
            # con esto evitamos "¿Eso es: uno ele cero O?"
            charset = "23456789ABCDEFGHJKLMNPQRSTUVWXYZ"
            code = Array.new(5) { charset.chars.sample }.join
            "#{prefix}-#{code}"
        end
    end
end
