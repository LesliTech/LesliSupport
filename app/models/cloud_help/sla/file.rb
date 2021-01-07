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
    class Sla::File < CloudObject::File
        belongs_to :cloud_object, class_name: "CloudHelp::Sla", foreign_key: 'cloud_help_slas_id'

        enum file_type: {
            images: "images",
            error_logs: "error_logs",
            drafts: "drafts",
            general_files: "general_files",
            other: "other"
        }
    end
end
