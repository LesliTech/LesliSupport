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
        before_action :set_ticket_assignment, only: [:show, :update]

        def create
            ticket = CloudHelp::Ticket.find_by(
                id: params[:ticket_id],
                cloud_help_accounts_id: current_user.account.id
            )
            if ticket.create_assignment(ticket_assignment_params)
                responseWithSuccessful(ticket.assignment)
            else
                responseWithError(ticket.error.full_messages.to_sentece)
            end
        end

        def show
            if @ticket_assignment
                responseWithSuccessful(@ticket_assignment)
            else
                responseWithSuccessful
            end
        end

        def update
            return responseWithNotFound unless @ticket_assignment

            if @ticket_assignment.update(ticket_assignment_params)
                responseWithSuccessful(@ticket_assignment)
            else
                responseWithError(ticket.error.full_messages.to_sentece)
            end
        end
        
=begin
@return [JSON] Json that contains a list of all users to wich a ticket can be assigned to.
@description Comunicates to the core using the *Courier* engine to retrieve a list of all the
    possible users a ticket can be assigned to.
@example
    possible_users = Courier::Core::Users.list
=end
        def assignment_options
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
            params.fetch(:assignment, {}).permit(:users_id, :cloud_team_teams_id, :assignation_type)
        end
    end
end
