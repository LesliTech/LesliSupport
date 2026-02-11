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


# · 
require "json"

# · 
file = File.open(LesliSupport::Engine.root.join("db", "seed", "seeds.json")).read
seeds = JSON.parse(file)

current_user = Lesli::User.first

catalog_types = current_user.account.support.catalogs.find_or_create_by!(:name => "Ticket Types")
catalog_types.items.find_or_create_by!(:name => "Development")
catalog_types.items.find_or_create_by!(:name => "Question")
catalog_types.items.find_or_create_by!(:name => "Bug")


catalog_categories = current_user.account.support.catalogs.find_or_create_by!(:name => "Ticket Categories")
catalog_categories.items.find_or_create_by!(:name => "User Management")
catalog_categories.items.find_or_create_by!(:name => "Role Management")
catalog_categories.items.find_or_create_by!(:name => "Account Management")

catalog_priorities = current_user.account.support.catalogs.find_or_create_by!(:name => "Ticket Priorities")
catalog_priorities.items.find_or_create_by!(:name => "Low", :order => 1)
catalog_priorities.items.find_or_create_by!(:name => "Medium", :order => 2)
catalog_priorities.items.find_or_create_by!(:name => "High", :order => 3)



seeds["tickets"].each_with_index do |ticket, index|

    # Determine which day this ticket belongs to
    day = ((Math.sqrt(8 * index + 1) - 1) / 2).floor + 1

    # Start from 10 days ago
    ticket_date = day.days.ago

    #
    current_user.account.support.tickets.create!({
        :subject => ticket["subject"],
        :description => ticket["description"],
        :deadline_at => ticket_date,
        :owner => Lesli::User.first.account.users.sample,
        :user => Lesli::User.first.account.users.sample,
        
        #:catalog_workspace => current_user.account.support.catalog_workspaces.first,
        :type => catalog_types.items.sample,
        :category => catalog_categories.items.sample,
        :priority => catalog_priorities.items.sample,
        :created_at => ticket_date
    })
end 
