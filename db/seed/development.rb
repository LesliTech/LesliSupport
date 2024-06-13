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

# · 
require "json"

# · 
file = File.open(LesliSupport::Engine.root.join("db", "seed", "seeds.json")).read
seeds = JSON.parse(file)


current_user = Lesli::User.first

current_user.account.support.catalog_workspaces.find_or_create_by!(:name => "Default", :default => true)

current_user.account.support.catalog_types.find_or_create_by!(:name => "development")
current_user.account.support.catalog_types.find_or_create_by!(:name => "question")
current_user.account.support.catalog_types.find_or_create_by!(:name => "bug")

current_user.account.support.catalog_categories.find_or_create_by!(:name => "user_namagement")
current_user.account.support.catalog_categories.find_or_create_by!(:name => "role_namagement")
current_user.account.support.catalog_categories.find_or_create_by!(:name => "account_namagement")

current_user.account.support.catalog_priorities.find_or_create_by!(:name => "low", :weight => 1)
current_user.account.support.catalog_priorities.find_or_create_by!(:name => "medium", :weight => 2)
current_user.account.support.catalog_priorities.find_or_create_by!(:name => "high", :weight => 3)


seeds["tickets"].each_with_index do |ticket, index|

    # Start tickets from 10 days ago
    ticket_date = (index - 10).days.from_now 

    #
    current_user.account.support.tickets.create!({
        :subject => ticket["subject"],
        :description => ticket["description"],
        :deadline => ticket_date,
        :user => current_user,
        :creator => current_user,
        :catalog_workspace => current_user.account.support.catalog_workspaces.first,
        :catalog_type => current_user.account.support.catalog_types.first,
        :catalog_category => current_user.account.support.catalog_categories.first,
        :catalog_priority => current_user.account.support.catalog_priorities.first
    })
end 
