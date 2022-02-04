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
class CreateCloudHelpCatalogTicketWorkspaces < ActiveRecord::Migration[6.1]
  def change
    create_table :cloud_help_catalog_ticket_workspaces do |t|
        t.string :name
        t.boolean :default, default: false

        # acts_as_paranoid
        t.datetime :deleted_at, index: true
        
        t.timestamps
    end

    add_reference :cloud_help_catalog_ticket_workspaces, :cloud_help_accounts, foreign_key: true, index: {name: "help_catalog_ticket_workspaces_accounts"}
    add_reference :cloud_help_tickets, :cloud_help_catalog_ticket_workspaces, foreign_key: true, index: { name: "help_tickets_catalog_ticket_workspaces" }

    # If there are acounts in the system, we add the Default Workspace
    CloudHelp::Account.all.each do |account|
        default_workspace = account.workspaces.find_by(default: true)

        account.workspaces.create!(name: "Default", default: true) unless default_workspace
    end
end
