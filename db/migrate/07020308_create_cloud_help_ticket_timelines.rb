class CreateCloudHelpTicketTimelines < ActiveRecord::Migration[6.0]
    def change
        create_table :cloud_help_ticket_timelines do |t|
            t.timestamps
        end
        add_reference :cloud_help_ticket_timelines, :cloud_help_tickets, foreign_key: true
    end
end
