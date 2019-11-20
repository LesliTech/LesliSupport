class CreateCloudHelpTicketWorkflows < ActiveRecord::Migration[6.0]
    def change
        create_table :cloud_help_ticket_workflows do |t|
            t.string :next_states
            t.timestamps
        end
        add_reference :cloud_help_ticket_workflows, :cloud_help_ticket_types, foreign_key: true, index: { name: 'help_ticket_workflows_types' }
        add_reference :cloud_help_ticket_workflows, :cloud_help_ticket_categories, foreign_key: true, index: { name: 'help_ticket_workflows_categories' }
        add_reference :cloud_help_ticket_workflows, :cloud_help_ticket_states, foreign_key: true, index: { name: 'help_ticket_workflows_states' }
    end
end
