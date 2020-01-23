class CreateCloudHelpTicketWorkflowStates < ActiveRecord::Migration[6.0]
    def change
        table_base_structure = JSON.parse(File.read(Rails.root.join('db','structure','00000010_workflow_states.json')))
        create_table :cloud_help_ticket_workflow_states do |t|
            table_base_structure.each do |column|
                t.send(
                    column["type"].parameterize.underscore.to_sym,
                    column["name"].parameterize.underscore.to_sym
                )
            end
            t.timestamps
        end
        add_reference :cloud_help_ticket_workflow_states, :cloud_help_accounts, foreign_key: true, index: { name: 'help_ticket_workflow_states_accounts' }
    end
end
