module CloudHelp
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
    class Ticket::Activity < CloudObject::Activity
        belongs_to :cloud_object, class_name: "CloudHelp::Ticket", foreign_key: "cloud_help_tickets_id", optional: true
        belongs_to :user, class_name: "::User", foreign_key: "users_id", optional: true

        enum category: {
            action_list:                    "action_list",
            action_create:                  "action_create",
            action_show:                    "action_show",
            action_update:                  "action_update",
            action_destroy:                 "action_destroy",
            action_status:                  "action_status",
            action_workflow_action_failed:  "action_workflow_action_failed",
            action_email_sent:              "action_email_sent",
            action_create_file:             "action_create_file",
            action_destroy_file:            "action_destroy_file",
            action_create_assignment:       "action_create_assignment",
            action_destroy_assignment:      "action_destroy_assignment"
        }
    end
end
    