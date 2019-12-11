class CreateCloudHelpTicketDetails < ActiveRecord::Migration[6.0]
    def change
        create_table    :cloud_help_ticket_details do |t|
            t.string    :subject 
            t.text      :description
            t.datetime  :deadline
            t.string    :tags
            t.timestamps
        end
        add_reference :cloud_help_ticket_details, :cloud_help_ticket_types, foreign_key: true, index: { name: 'help_ticket_details_types' }
        add_reference :cloud_help_ticket_details, :cloud_help_ticket_workflows, foreign_key: true, index: { name: 'help_ticket_details_workflows' }
        add_reference :cloud_help_ticket_details, :cloud_help_ticket_priorities, foreign_key: true, index: { name: 'help_ticket_details_priorities' }
        add_reference :cloud_help_ticket_details, :cloud_help_ticket_sources, foreign_key: true, index: { name: 'help_ticket_details_sources' }
        add_reference :cloud_help_ticket_details, :cloud_help_ticket_categories, foreign_key: true, index: { name: 'help_ticket_details_categories' }
        add_reference :cloud_help_ticket_details, :cloud_help_tickets, foreign_key: true
    end
end
