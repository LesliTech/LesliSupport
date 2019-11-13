class CreateCloudHelpTicketInitialPriorities < ActiveRecord::Migration[6.0]
    def change
        create_table :cloud_help_ticket_initial_priorities do |t|
            t.timestamps
        end
        add_reference :cloud_help_ticket_initial_priorities, :cloud_help_ticket_types, foreign_key: true, index: { name: 'help_ticket_initial_priorities_types' }
        add_reference :cloud_help_ticket_initial_priorities, :cloud_help_ticket_categories, foreign_key: true, index: { name: 'help_ticket_initial_priorities_categories' }
        add_reference :cloud_help_ticket_initial_priorities, :cloud_help_ticket_priorities, foreign_key: true, index: { name: 'help_ticket_initial_priorities_priorities' }
    end
end
