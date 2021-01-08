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
require_dependency "cloud_help/application_controller"

module CloudHelp
    class Workflow::AssociationsController < Shared::Workflow::AssociationsController

=begin
@return [Parameters] Allowed parameters for the workflow
@description Sanitizes the parameters received from an HTTP call to only allow the specified ones.
    If there are extra allowed params, they must be implemented on the subclass
@example
    # supose params contains {
    #    workflow_association: {
    #       workflow_for: 'projects'
    #       id: 10
    #    }
    #}
    filtered_params = association_params
    puts filtered_params
    # will remove the unpermitted params and only print {
    #       workflow_for: 'projects'
    #    }
=end
        def association_params
            dynamic_info = self.class.dynamic_info
            module_name = dynamic_info[:module_name]

            params.require(:workflow_association).permit(
                :workflow_for,
                :global,
                :ticket_type,
                :ticket_category
            )
        end

    end
end
