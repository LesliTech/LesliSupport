module CloudHelp
=begin

Lesli

Copyright (c) 2020, Lesli Technologies, S. A.

All the information provided by this website is protected by laws of Guatemala related 
to industrial property, intellectual property, copyright and relative international laws. 
Lesli Technologies, S. A. is the exclusive owner of all intellectual or industrial property
rights of the code, texts, trade mark, design, pictures and any other information.
Without the written permission of Lesli Technologies, S. A., any replication, modification,
transmission, publication is strictly forbidden.
For more information read the license file including with this software.

LesliCloud - Your Smart Business Assistant

Powered by https://www.lesli.tech
Building a better future, one line of code at a time.

@author   Carlos Hermosilla
@license  Propietary - all rights reserved.
@version  0.1.0-alpha
@description Model for ticket assignments. An assigment is associated to a ticket. 
@todo Provide support to assign tickets to a *CloudTeams::Team*
=end
    class Ticket::Assignment < ApplicationRecord
        include ActiveModel::Dirty
        
        belongs_to :ticket, inverse_of: :assignment, foreign_key: 'cloud_help_tickets_id'
        belongs_to :user, class_name: 'User', foreign_key: 'users_id'

        after_create :create_notifications_events
        after_update :create_notifications_events

=begin
@attribute [Enumerable<Symbol>] assignation_type
    @return [ :user, :team ]
=end
        enum assignation_type: [:user, :team]
        validates :assignation_type, presence: true, inclusion: { in: :assignation_type }

        private

=begin
@return [void]
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
        def create_notifications_events
            user_change = saved_changes["users_id"]
            if user_change
                ticket.timelines.create(
                    action: Ticket::Timeline.actions[:assigned_to_user],
                    description: I18n.t(
                        'activerecord.models.cloud_help/ticket/timeline.actions.assigned_to_user',
                        user: user.email
                    )
                )
        
                Courier::Driver::Calendar.registerEvent(
                    user, {
                        title:          I18n.t('activerecord.models.cloud_help_ticket.expected_response_time.title', ticket_id: ticket.id),
                        description:    I18n.t('activerecord.models.cloud_help_ticket.expected_response_time.description'),
                        time_start:     DateTime.now + ticket.detail.workflow_detail.ticket_workflow.sla.expected_response_time.hour,
                        url:            "/help/tickets/#{id}"
                    }
                )
        
                Courier::Driver::Calendar.registerEvent(
                    user, {
                        title:          I18n.t('activerecord.models.cloud_help_ticket.expected_resolution_time.title', ticket_id: ticket.id),
                        description:    I18n.t('activerecord.models.cloud_help_ticket.expected_resolution_time.description'),
                        time_start:     DateTime.now + ticket.detail.workflow_detail.ticket_workflow.sla.expected_resolution_time.hour,
                        url:            "/help/tickets/#{id}"
                    }
                )
        
                message = I18n.t(
                    'activerecord.models.cloud_help_ticket.updated.assigned',
                    ticket_id: ticket.id,
                    user: user.email
                )
                Ticket::Subscriber.notify_subscribers(ticket, message, :assignment_updated)
            end
        end
    end
end
