class CreateCloudHelpSlaAssignments < ActiveRecord::Migration[6.0]
    def change
        create_table :cloud_help_sla_assignments do |t|
            t.string :next_sla
            t.timestamps
        end
        add_reference :cloud_help_sla_assignments, :cloud_help_ticket_types, foreign_key: true, index: { name: 'help_ticket_sla_assignments_types' }
        add_reference :cloud_help_sla_assignments, :cloud_help_ticket_categories, foreign_key: true, index: { name: 'help_ticket_sla_assignments_categories' }
        add_reference :cloud_help_sla_assignments, :cloud_help_slas, foreign_key: true, index: { name: 'help_sla_assignments_slas' }
    end
end
