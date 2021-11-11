class CreateCloudHelpTicketAssignments < ActiveRecord::Migration[6.0]
    def change
        create_table :cloud_help_ticket_assignments do |t|
            t.bigint :team_id
            t.string :assignment_type

            # acts_as_paranoid
            t.datetime :deleted_at, index: true

            t.timestamps
        end
        add_reference :cloud_help_ticket_assignments, :cloud_help_tickets, foreign_key: true
        add_reference :cloud_help_ticket_assignments, :users, foreign_key: true
    end
end
