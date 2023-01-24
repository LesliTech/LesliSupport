require_dependency "cloud_help/application_controller"

module CloudHelp
=begin

Copyright (c) 2023, all rights reserved.

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
    class Ticket::TimelinesController < ApplicationLesliController

=begin
@return [JSON] Json that contains a list of all events in the ticket timeline
@description Retrieves and returns all timeline events associated to a *CloudHelp::Ticket*.
    The timeline is also filtered by *account* and *current_user* is also used.
@example
    # Executing this controller's action from javascript's frontend
    this.http.get(`127.0.0.1/help/ticket_priorities`);
=end
        def index
            respond_with_successful(Ticket::Timeline.index(current_user, @query, params[:ticket_id]))
        end

        def options
            respond_with_successful(Ticket::Timeline.options(current_user, @query))
        end
    end
end
