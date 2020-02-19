class CreateCloudHelpWorkflowStatuses < ActiveRecord::Migration[6.0]
    def change
        table_base_structure = JSON.parse(File.read(Rails.root.join("db","structure","00000202_workflow_statuses.json")))
        create_table :cloud_help_workflow_statuses do |t|
            table_base_structure.each do |column|
                t.send(
                    column["type"].parameterize.underscore.to_sym,
                    column["name"].parameterize.underscore.to_sym
                )
            end
            t.timestamps
        end
        add_reference :cloud_help_workflow_statuses, :cloud_help_workflows, foreign_key: true, index: { name: "help_workflow_statuses_workflows" }
    end
end
