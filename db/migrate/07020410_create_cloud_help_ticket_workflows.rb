class CreateCloudHelpTicketWorkflows < ActiveRecord::Migration[6.0]
    def change
        create_table :cloud_help_ticket_workflows do |t|
            t.timestamps
        end
        add_reference :cloud_help_ticket_workflows, :cloud_help_ticket_types, foreign_key: true, index: {name: 'help_ticket_workflows_type' }
        add_reference :cloud_help_ticket_workflows, :cloud_help_ticket_categories, foreign_key: true, index: {name: 'help_ticket_workflows_category'}
        add_reference :cloud_help_ticket_workflows, :cloud_help_workflows, foreign_key: true, index: {name: 'help_ticket_workflows_workflow'}
        add_reference :cloud_help_ticket_workflows, :cloud_help_accounts, foreign_key: true, index: {name: 'help_ticket_workflows_account'}
    end
end
