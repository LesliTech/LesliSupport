class CreateCloudHelpTicketAssignments < ActiveRecord::Migration[6.0]
    def change
        create_table :cloud_help_ticket_assignments do |t|
            t.bigint :assignable_id
            t.string :assignable_type
            t.timestamps
        end
        add_reference :cloud_help_ticket_assignments, :cloud_help_tickets, foreign_key: true
    end
end
