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
@description Model for ticket timelines. A timeline registers each one of the ticket's important
    actions (like priority change, or state change). These actions are listed in the *action* enum

=end
    class Ticket::Timeline < ApplicationLesliRecord
        belongs_to :ticket, class_name: 'CloudHelp::Ticket', foreign_key: 'cloud_help_tickets_id'

=begin
@attribute [Enumerable<Symbol>] event
    @return [ :status_changed, :priority_increased, :priority_decreased, :category_transferred, :type_transferred, :created, :closed, :assigned_to_user, :deadline_established ]
=end
        enum action: {
            created: "created",
            assigned_to_user: "assigned_to_user",
            unassigned_from_user: "unassigned_from_user",
            status_changed: "status_changed",
            priority_changed: "priority_changed",
            category_transferred: "category_transferred",
            type_transferred: "type_transferred",
            deadline_established: "deadline_established",
            closed: "closed"
        }

        def self.index(current_user, query, ticket_id)
            ticket = current_user.account.help.tickets.find_by(id: ticket_id)
            return [] unless ticket

            timelines = ticket.timelines.order(id: :desc).map do |timeline|
                timeline_attributes = timeline.attributes
                timeline_attributes["created_at"] = LC::Date.to_string_datetime(timeline_attributes["created_at"])

                timeline_attributes
            end

            timelines
        end

        def self.options(current_user, query)
            option_actions = actions.map do |key, value|
                {
                    value: key,
                    text: value
                }
            end

            option_actions = option_actions

            {
                actions: option_actions
            }
        end
    end
end
