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
    class TicketState < ApplicationRecord
        belongs_to :account, class_name: 'CloudHelp::Account', foreign_key: 'cloud_help_accounts_id' 
        has_many :details, class_name: 'CloudHelp::Ticket::Detail', foreign_key: 'cloud_help_ticket_states_id'
        has_many :ticket_workflow_details, class_name: 'CloudHelp::TicketWorkflow::Detail', foreign_key: 'cloud_help_ticket_states_id'

        validates :name, presence: true
=begin
@return [Boolean] Wheter the ticket state was deleted or not
@description Attempts to delete this ticket state.
    However, if there is a *ticket* *workflow* associated to this *state*, it 
    will not be deleted and an error will be added to the *errors* parameter.
    States that are initial or final cannot be deleted
@example
    my_state = CloudHelp::TicketState.first
    if my_state.destroy
        puts "Ticket state successfully destroyed"
    else
        puts "Ticket state was not destroyed"
        puts my_state.errors.full_messages.to_sentence
    end
=end
        def destroy
            begin
                if initial || final
                    errors.add(:base, :destroy_attempt_on_default_state)
                    return false
                end
                super
            rescue ActiveRecord::InvalidForeignKey
                errors.add(:base, :foreign_key_prevents_destruction)
                false
            end
        end

=begin
@return [Boolean] Wheter the ticket state is final or not
@description Returns a value based on wheter this ticket state is final or not
@example
    my_state = CloudHelp::TicketState.first
    if my_state.is_final?
        puts "This is a final state"
    else
        puts "This is not a final state"
    end
=end
        def is_final?
            final
        end

=begin
@return [Boolean] Wheter the ticket state is initial or not
@description Returns a value based on wheter this ticket state is initial or not
@example
    my_state = CloudHelp::TicketState.first
    if my_state.is_initial?
        puts "This is an initial state"
    else
        puts "This is not a initial state"
    end
=end
        def is_initial?
            initial
        end

=begin
@return [CloudHelp::TicketState] The initial state of this account
@description Returns the state tagged as initial
@example
    initial_state = CloudHelp::TicketState.initial_state
    puts initial_state
=end
        def self.initial_state
            return TicketState.find_by(initial: true)
        end

=begin
@return [CloudHelp::TicketState] The final state of this account
@description Returns the state tagged as final
@example
    final_state = CloudHelp::TicketState.final_state
    puts final_state
=end
        def self.final_state
            return TicketState.find_by(final: true)
        end
        
    end
end
