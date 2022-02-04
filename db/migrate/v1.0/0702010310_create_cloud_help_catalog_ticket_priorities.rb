class CreateCloudHelpCatalogTicketPriorities < ActiveRecord::Migration[6.0]
    def change
        create_table :cloud_help_catalog_ticket_priorities do |t|
            t.string :name
            t.integer :weight

            # acts_as_paranoid
            t.datetime :deleted_at, index: true
            
            t.timestamps
        end

        add_reference :cloud_help_catalog_ticket_priorities, :cloud_help_accounts, foreign_key: true, index: {name: "help_catalog_ticket_priorities_accounts"}
    end
end
