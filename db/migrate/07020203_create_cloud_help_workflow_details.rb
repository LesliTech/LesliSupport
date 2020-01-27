class CreateCloudHelpWorkflowDetails < ActiveRecord::Migration[6.0]
    def change
        table_base_structure = JSON.parse(File.read(Rails.root.join('db','structure','00000203_workflow_details.json')))
        create_table :cloud_help_workflow_details do |t|
            table_base_structure.each do |column|
                t.send(
                    column["type"].parameterize.underscore.to_sym,
                    column["name"].parameterize.underscore.to_sym
                )
            end
            t.timestamps
        end
        add_reference :cloud_help_workflow_details, :cloud_help_workflows, foreign_key: true, index: { name: 'help_workflow_details' }
        add_reference :cloud_help_workflow_details, :cloud_help_workflow_states, foreign_key: true, index: { name: 'help_workflow_details_states' }
    end
end
