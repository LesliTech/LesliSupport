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
module CloudHelp
    class TicketMailer < ApplicationLesliMailer

        def assignment
            user = params[:user]
            ticket = params[:ticket]

            @data = @data.merge({
                url: "/help/tickets/#{ticket.id}/edit",
                title: I18n.t("help.tickets.mailer_ticket_assignment_subject"),
                link_information: I18n.t("help.tickets.mailer_ticket_assignment_link_information"),
                link_text: I18n.t("help.tickets.mailer_ticket_assignment_link_text"),
                user: {
                    full_name: user.full_name
                }
            })

            mail(
                to: email_address_with_name(user.email, user.full_name), 
                subject: I18n.t("help.tickets.mailer_ticket_assignment_subject")
            )
        end
    end
end
