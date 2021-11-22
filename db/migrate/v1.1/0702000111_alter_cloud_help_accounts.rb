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
class AlterCloudHelpAccounts < ActiveRecord::Migration[6.1]
    def change
        add_column :cloud_help_accounts, :created_at, :datetime, null: false, default: -> { "NOW()" }
        add_column :cloud_help_accounts, :updated_at, :datetime, null: false, default: -> { "NOW()" }
    end
end
