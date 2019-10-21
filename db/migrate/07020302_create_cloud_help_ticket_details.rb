class CreateCloudHelpTicketDetails < ActiveRecord::Migration[6.0]
    def change
        create_table :cloud_help_ticket_details do |t|
            t.string :subject 
            t.text   :description
            t.string :tags
            t.timestamps
        end
        add_reference :cloud_help_ticket_details, :cloud_help_ticket_types, foreign_key: true, index: { name: 'help_ticket_details_types' }
        add_reference :cloud_help_ticket_details, :cloud_help_ticket_states, foreign_key: true, index: { name: 'help_ticket_details_states' }
        add_reference :cloud_help_ticket_details, :cloud_help_ticket_priorities, foreign_key: true, index: { name: 'help_ticket_details_priorities' }
        add_reference :cloud_help_ticket_details, :cloud_help_tickets, foreign_key: true
    end
end
