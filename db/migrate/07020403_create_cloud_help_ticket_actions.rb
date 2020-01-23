class CreateCloudHelpTicketActions < ActiveRecord::Migration[6.0]
    def change
        table_base_structure = JSON.parse(File.read(Rails.root.join('db','structure','00000000_actions.json')))
        create_table :cloud_help_ticket_actions do |t|
            table_base_structure.each do |column|
                t.send(
                    column["type"].parameterize.underscore.to_sym,
                    column["name"].parameterize.underscore.to_sym
                )
            end
            t.timestamps
        end
        add_reference :cloud_help_ticket_actions, :cloud_help_tickets, foreign_key: true
    end
end
