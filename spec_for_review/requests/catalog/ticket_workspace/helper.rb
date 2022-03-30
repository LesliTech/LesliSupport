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
module Requests
    module Catalog
        module TicketWorkspace
            module Helper
                def build_random_workspace(user, default: false)
                    workspace = user.account.help.ticket_workspaces.new({
                        name: Faker::Lorem.word,
                        default: default
                    })
                    workspace.save!

                    return workspace
                end

                def workspace_params(user, default: false)
                    {
                        ticket_workspace: {
                            name: Faker::Lorem.word,
                            default: default
                        }
                    }
                end
            end
        end
    end
end
