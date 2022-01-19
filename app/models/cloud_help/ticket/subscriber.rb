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
    class Ticket::Subscriber < CloudObject::Subscriber
        belongs_to :cloud_object, class_name: "CloudHelp::Ticket", foreign_key: "cloud_help_tickets_id"

        # @attribute [Enumerable<Symbol>] action
        #     @return [:object_status_updated, :discussion_created]
        enum action: {
            object_status_updated: "object_status_updated",

            discussion_created: "discussion_created"
        }
    end
end
