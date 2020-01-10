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
@description Controller for ticket timelines. Timeline entries are created once changes occur
    in the ticket (like when a user escalates the ticket)

=end
  class Ticket::TimelinesController < ApplicationController
    before_action :set_ticket_timelines, only: [:index]

=begin
@return [JSON] Json that contains a list of all events in the ticket timeline
@description Retrieves and returns all timeline events associated to a *CloudHelp::Ticket*. 
    The timeline is also filtered by *account* and *current_user* is also used.
@example
    # Executing this controller's action from javascript's frontend
    this.http.get(`127.0.0.1/help/ticket_priorities`);
=end
    def index
        responseWithSuccessful(@ticket_timelines)
    end

    private

=begin
@return [void]
@description Sets the variable @ticket_timelines. The variable contains an array of 
    *CloudHelp::Ticket::Timeline* associated to a ticket.
@example
    #suppose params[:ticket_id] = 1
    puts @ticket_timelines # will display nil
    set_ticket_timelines
    puts @ticket_timelines # will display an array with several instances of CloudHelp:Ticket::Timeline
=end
    def set_ticket_timelines
        ticket_id = params[:ticket_id]
        @ticket_timelines = current_user.account.help.tickets.find(ticket_id).timelines
    end
  end
end
