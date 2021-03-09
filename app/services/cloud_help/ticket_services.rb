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
    class TicketServices

        def self.create(current_user, ticket_params)
            ticket = Ticket.new(ticket_params)
            ticket.source = Catalog::TicketSource.cloud_help_source(current_user.account.help)
            ticket.account = current_user.account.help
            ticket.user_creator = current_user
            ticket.set_sla
            ticket.set_workflow

            if ticket.save
                Ticket.log_activity_create(current_user, ticket)
                Workflow::Action.execute_actions(current_user, ticket, {}, ticket.attributes)

                return LC::Response.service(true, ticket)
            else
                return LC::Response.service(false, ticket)
            end
        end

    end
end
