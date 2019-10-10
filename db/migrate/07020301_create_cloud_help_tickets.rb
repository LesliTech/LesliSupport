class CreateCloudHelpTickets < ActiveRecord::Migration[6.0]
    def change
        create_table :cloud_help_tickets do |t|
            t.timestamps
        end
        add_reference :cloud_help_tickets, :cloud_help_accounts, foreign_key: true
    end
end
