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

=begin
@return [JSON] Json that contains a list of all users to wich a ticket can be assigned to.
@description Comunicates to the core using the *Courier* engine to retrieve a list of all the
    possible users a ticket can be assigned to.
@example
    possible_users = Courier::Core::Users.list
=end
        def index
            responseWithSuccessful(Courier::Core::Users.list)
        end
    end
end
