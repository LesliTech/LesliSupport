=begin

Copyright (c) 2022, all rights reserved.

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
class AlterCloudHelpTickets < ActiveRecord::Migration[6.1]
    def change
        add_reference :cloud_help_tickets, :cloud_help_catalog_ticket_workspaces, foreign_key: true, index: { name: "help_tickets_catalog_ticket_workspaces" }

        # If there are acounts in the system, we add the Default Workspace
        CloudHelp::Account.all.each do |account|
            default_workspace = account.ticket_workspaces.find_by(default: true)

            default_workspace = account.ticket_workspaces.create!(name: "Default", default: true) unless default_workspace

            account.tickets.all.each do |ticket|
                ticket.update!(workspace: default_workspace)
            end
        end
    end
end
