class CreateCloudHelpTicketStateAssignments < ActiveRecord::Migration[6.0]
    def change
        create_table :cloud_help_ticket_state_assignments do |t|
            t.string :next_states
            t.timestamps
        end
        add_reference :cloud_help_ticket_state_assignments, :cloud_help_ticket_types, foreign_key: true, index: { name: 'help_ticket_state_assignments_types' }
        add_reference :cloud_help_ticket_state_assignments, :cloud_help_ticket_categories, foreign_key: true, index: { name: 'help_ticket_state_assignments_categories' }
        add_reference :cloud_help_ticket_state_assignments, :cloud_help_ticket_states, foreign_key: true, index: { name: 'help_ticket_state_assignments_states' }
    end
end
