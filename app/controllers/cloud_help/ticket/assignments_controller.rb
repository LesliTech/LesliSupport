require_dependency "cloud_help/application_controller"

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
@description Controller for ticket assignments

=end
    class Ticket::AssignmentsController < ApplicationController
        before_action :set_ticket_assignment, only: [:update, :destroy]

        def create
        end

        def show
            responseWithSuccessful
        end

        def update
        end

        def destroy
        end

        
=begin
@return [JSON] Json that contains a list of all users to wich a ticket can be assigned to.
@description Comunicates to the core using the *Courier* engine to retrieve a list of all the
    possible users a ticket can be assigned to.
@example
    possible_users = Courier::Core::Users.list
=end
        def assignments_options
            responseWithSuccessful(Courier::Core::Users.list)
        end

        private

        def set_ticket_assignment
            @ticket_assignment = CloudHelp::Ticket::Assignment.joins(:ticket).find_by(
                "cloud_help_tickets.id = #{params[:ticket_id]}",
                "cloud_help_tickets.cloud_help_accounts_id = #{current_user.account.id}"
            )
        end

        def ticket_assignment_params
        end
    end
end

=begin
,
                assignment_attributes: [
                    :users_id,
                    :cloud_team_teams_id,
                    :assignation_type
                ]
=end

=begin
    def action_register_assignment_change
        timelines.create(
            action: Ticket::Timeline.actions[:assigned_to_user],
            description: I18n.t(
                'activerecord.models.cloud_help/ticket/timeline.actions.assigned_to_user',
                user: assignment.user.email
            )
        )

        Courier::Driver::Calendar.registerEvent(
            assignment.user, {
                title:          I18n.t('activerecord.models.cloud_help_ticket.expected_response_time.title', ticket_id: id),
                description:    I18n.t('activerecord.models.cloud_help_ticket.expected_response_time.description'),
                time_start:     DateTime.now + detail.workflow_detail.ticket_workflow.sla.expected_response_time.hour,
                url:            "/help/tickets/#{id}"
            }
        )

        Courier::Driver::Calendar.registerEvent(
            assignment.user, {
                title:          I18n.t('activerecord.models.cloud_help_ticket.expected_resolution_time.title', ticket_id: id),
                description:    I18n.t('activerecord.models.cloud_help_ticket.expected_resolution_time.description'),
                time_start:     DateTime.now + detail.workflow_detail.ticket_workflow.sla.expected_resolution_time.hour,
                url:            "/help/tickets/#{id}"
            }
        )

        message = I18n.t(
            'activerecord.models.cloud_help_ticket.updated.assigned',
            ticket_id: id,
            user: assignment.user.email
        )
        Ticket::Subscriber.notify_subscribers(self, message, :assignment_updated)
    end
=end
