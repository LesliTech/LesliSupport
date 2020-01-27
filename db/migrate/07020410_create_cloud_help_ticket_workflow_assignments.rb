class CreateCloudHelpTicketWorkflowAssignments < ActiveRecord::Migration[6.0]
    def change
        create_table :cloud_help_ticket_workflow_assignments do |t|
            t.timestamps
        end
        add_reference :cloud_help_ticket_workflow_assignments, :cloud_help_ticket_types, foreign_key: true, index: {name: 'help_ticket_workflow_assignments_type' }
        add_reference :cloud_help_ticket_workflow_assignments, :cloud_help_ticket_categories, foreign_key: true, index: {name: 'help_ticket_workflow_assignments_category'}
        add_reference :cloud_help_ticket_workflow_assignments, :cloud_help_workflows, foreign_key: true, index: {name: 'help_ticket_workflow_assignments_workflow'}
        add_reference :cloud_help_ticket_workflow_assignments, :cloud_help_accounts, foreign_key: true, index: {name: 'help_ticket_workflow_assignments_account'}
    end
end
