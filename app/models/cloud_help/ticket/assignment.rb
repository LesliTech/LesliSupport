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

=begin
@attribute [Enumerable<Symbol>] assignation_type
    @return [ :user, :team ]
=end
        enum assignation_type: [:user, :team]
        validates :assignation_type, presence: true, inclusion: { in: :assignation_type }
    end
end
