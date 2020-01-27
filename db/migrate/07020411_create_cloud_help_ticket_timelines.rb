class CreateCloudHelpTicketTimelines < ActiveRecord::Migration[6.0]
    def change
        create_table :cloud_help_ticket_timelines do |t|
            # action will be an enum
            t.integer :action
            # description is a small text describing that happened to the ticket
            t.string :description
            t.timestamps
        end
        add_reference :cloud_help_ticket_timelines, :cloud_help_tickets, foreign_key: true
    end
end
