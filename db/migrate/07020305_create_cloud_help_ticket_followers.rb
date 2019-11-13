class CreateCloudHelpTicketFollowers < ActiveRecord::Migration[6.0]
    def change
        create_table :cloud_help_ticket_followers do |t|
            t.datetime :deleted_at
            t.timestamps
        end
        add_reference :cloud_help_ticket_followers, :cloud_help_tickets, foreign_key: true
        add_reference :cloud_help_ticket_followers, :users, foreign_key: true
    end
end
