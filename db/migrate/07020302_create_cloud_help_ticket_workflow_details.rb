class CreateCloudHelpTicketWorkflowDetails < ActiveRecord::Migration[6.0]
    def change
        create_table :cloud_help_ticket_workflow_details do |t|
            t.string :next_states
            t.timestamps
        end
        add_reference :cloud_help_ticket_workflow_details, :cloud_help_ticket_workflows, foreign_key: true, index: { name: 'help_ticket_workflow_details' }
        add_reference :cloud_help_ticket_workflow_details, :cloud_help_ticket_states, foreign_key: true, index: { name: 'help_ticket_workflow_details_states' }
    end
end
