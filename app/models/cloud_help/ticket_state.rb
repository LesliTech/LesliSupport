module CloudHelp
    class TicketState < ApplicationRecord
        belongs_to :account, class_name: 'CloudHelp::Account', foreign_key: 'cloud_help_accounts_id'
        
        has_many :details, class_name: 'CloudHelp::Ticket::Detail', foreign_key: 'cloud_help_ticket_states_id'
        has_many :ticket_workflows, class_name: 'CloudHelp::TicketWorkflow', foreign_key: 'cloud_help_ticket_states_id'

        def destroy
            if initial || final
                errors.add(:base, :destroy_attempt_on_default_state)
                return false
            end
            super
        end

        def is_final?
            final
        end

        def is_initial?
            initial
        end

        # Initial state is also record #1 in the database
        def self.initial_state
            return TicketState.find_by(initial: true)
        end
    end
end
