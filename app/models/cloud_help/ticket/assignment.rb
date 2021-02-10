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
    class Ticket::Assignment < ApplicationLesliRecord
        include ActiveModel::Dirty
        
        belongs_to :ticket, foreign_key: "cloud_help_tickets_id"
        belongs_to :user, class_name: "::User", foreign_key: "users_id"

        after_create    :action_register_ticket_assigned
        after_destroy   :action_register_ticket_unassigned

=begin
@attribute [Enumerable<Symbol>] assignation_type
    @return [ :user, :team ]
=end
        enum assignment_type: {
            user: "user",
            team: "team"
        }

        def self.send_email_create(assigned_user, ticket)
            receipt = assigned_user.email
            title = "#{ticket.id} - #{ticket.subject}"

            data = {
                name: assigned_user.full_name,
                title: title,
                href: "/help/tickets/#{ticket.id}/edit"
            }
            
            email =  HelpMailer.ticket_new(receipt, I18n.t("help.tickets.mailer_new_project_subject"), data)
            if deliver_now
                email.deliver_now
            else
                email.deliver_later
            end
        end

        private

=begin
@return [void]
@todo Create notifications after the SLA assignment has been made
@description After the assignation is created or updated, registers en entry in the timeline
    of the ticket, adds some events in CloudDriver and sends a notification to all subscribers.
    The events registered are:
    - Expected response time
    - Expected resolution time
@example
    assignment_params = {
        users_id: User.first.id,
        assignation_type: 'user'
    }
    CloudHelp::Ticket.find(1).create_assignment(assignment_params)
    # The notifications will be sent automatically after the update
=end
        def action_register_ticket_assigned
            ticket.timelines.create(
                action: Ticket::Timeline.actions[:assigned_to_user],
                description: user.full_name
            )
        end

        def action_register_ticket_unassigned
            ticket.timelines.create(
                action: Ticket::Timeline.actions[:unassigned_from_user],
                description: user.full_name
            )
        end
    end
end
