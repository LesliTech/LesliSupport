module CloudHelp
    class TicketType < ApplicationRecord
        belongs_to :account, class_name: 'CloudHelp::Account', foreign_key: 'cloud_help_accounts_id'
        
        has_many :details, class_name: 'CloudHelp::Ticket::Detail', foreign_key: 'cloud_help_ticket_types_id'
        has_many :state_assignments, class_name: 'CloudHelp::TicketState::Assignment',  foreign_key: 'cloud_help_ticket_types_id', dependent: :delete_all

        def assign_default_states
            initial_state = TicketState.find_by(initial: true)
            final_state = TicketState.find_by(final: true)

            TicketCategory.all.each do |ticket_category|
                TicketState::Assignment.create(
                    ticket_state: initial_state,
                    ticket_type: self,
                    ticket_category: ticket_category,
                    next_states: "#{final_state.id}"
                )
                TicketState::Assignment.create(
                    ticket_state: final_state,
                    ticket_type: self,
                    ticket_category: ticket_category
                )
            end
        end
    end
end
