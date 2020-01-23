class CreateCloudHelpTicketCategories < ActiveRecord::Migration[6.0]
    def change
        create_table :cloud_help_ticket_categories do |t|
            t.string :name
            t.string :ancestry
            t.timestamps
        end
        add_reference :cloud_help_ticket_categories, :cloud_help_accounts, foreign_key: true
        add_index :cloud_help_ticket_categories, :ancestry
    end
end
