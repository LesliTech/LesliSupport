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
@description Model for ticket types

=end
    class Catalog::TicketType < ApplicationRecord

        belongs_to  :account, class_name: "CloudHelp::Account",     foreign_key: "cloud_help_accounts_id"
        has_many    :tickets, class_name: "CloudHelp::Ticket",      foreign_key: "cloud_help_catalog_ticket_types_id"


        validates :name, presence: true

=begin
@return [Boolean] Wheter the ticket type was deleted or not
@description Attempts to delete this ticket type along with it's associated *workflow*.
    However, if there is a *ticket* associated to this *type*, it will not be deleted
    and an error will be added to the *errors* parameter
@example
    my_type = CloudHelp::TicketType.first
    if my_type.destroy
        puts "Ticket type successfully destroyed"
    else
        puts "Ticket type was not destroyed"
        puts my_type.errors.full_messages.to_sentence
    end
=end
        def destroy
            begin
                super
            rescue ActiveRecord::InvalidForeignKey
                errors.add(:base, :foreign_key_prevents_destruction)
                false
            end
        end
    end
end
    