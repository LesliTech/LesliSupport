class CreateCloudHelpTicketDetails < ActiveRecord::Migration[6.0]
    def change
        create_table :cloud_help_ticket_details do |t|
            t.string :subject 
            t.timestamps
        end
        add_reference :cloud_help_ticket_details, :cloud_help_tickets, foreign_key: true
    end
end
