class CreateCloudHelpTicketSources < ActiveRecord::Migration[6.0]
    def change
        create_table :cloud_help_ticket_sources do |t|
            t.string :name
            t.timestamps
        end
        add_reference :cloud_help_ticket_sources, :cloud_help_accounts, foreign_key: true
    end
end
