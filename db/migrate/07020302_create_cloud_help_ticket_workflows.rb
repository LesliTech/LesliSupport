class CreateCloudHelpTicketWorkflows < ActiveRecord::Migration[6.0]
    def change
        table_base_structure = JSON.parse(File.read(Rails.root.join('db','structure','00000011_workflows.json')))
        create_table :cloud_help_ticket_workflows do |t|
            table_base_structure.each do |column|
                t.send(
                    column["type"].parameterize.underscore.to_sym,
                    column["name"].parameterize.underscore.to_sym
                )
            end
            t.timestamps
        end
        add_reference :cloud_help_ticket_workflows, :cloud_help_accounts, foreign_key: true, index: { name: 'help_ticket_workflows_accounts' }
    end
end
