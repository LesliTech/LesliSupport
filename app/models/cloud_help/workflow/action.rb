=begin

Copyright (c) 2020, all rights reserved.

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
module CloudHelp
    class Workflow::Action < Shared::Workflow::Action
        belongs_to :workflow, class_name: "Workflow", foreign_key: "cloud_help_workflows_id"
        belongs_to :workflow_including_deleted, class_name: "Workflow", foreign_key: "cloud_help_workflows_id", with_deleted: true
        belongs_to :initial_status, class_name: "Workflow::Status", foreign_key: "initial_status_id", optional: true
        belongs_to :final_status, class_name: "Workflow::Status", foreign_key: "final_status_id"

    end
end
