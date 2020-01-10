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
@description Model for ticket priorities

=end
    class TicketPriority < ApplicationRecord

        belongs_to :account, class_name: 'CloudHelp::Account', foreign_key: 'cloud_help_accounts_id'

        has_many :details, class_name: 'CloudHelp::Ticket::Detail', foreign_key: 'cloud_help_ticket_priorities_id'

=begin
@return [Boolean] Wheter the ticket priority was deleted or not
@description Attempts to delete this ticket priority.
    However, if there is a *ticket* associated to this *priority*, it 
    will not be deleted and an error will be added to the *errors* parameter
@example
    my_priority = CloudHelp::TicketPriority.first
    if my_priority.destroy
        puts "Ticket priority successfully destroyed"
    else
        puts "Ticket priority was not destroyed"
        puts my_priority.errors.full_messages.to_sentence
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
