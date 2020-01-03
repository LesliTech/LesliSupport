class CreateCloudHelpTicketWorkflows < ActiveRecord::Migration[6.0]
    def change
        create_table :cloud_help_ticket_workflows do |t|
            t.timestamps
        end
        add_reference :cloud_help_ticket_workflows, :cloud_help_ticket_types, foreign_key: true, index: { name: 'help_ticket_workflows_types' }
        add_reference :cloud_help_ticket_workflows, :cloud_help_ticket_categories, foreign_key: true, index: { name: 'help_ticket_workflows_categories' }
        add_reference :cloud_help_ticket_workflows, :cloud_help_slas, foreign_key: true, index: {name: 'help_ticket_workflows_slas'}
    end
end
