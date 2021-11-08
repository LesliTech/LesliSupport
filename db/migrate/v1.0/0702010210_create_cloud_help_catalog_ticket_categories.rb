class CreateCloudHelpCatalogTicketCategories < ActiveRecord::Migration[6.0]
    def change
        create_table :cloud_help_catalog_ticket_categories do |t|
            t.string :name
            t.string :ancestry

            # acts_as_paranoid
            t.datetime :deleted_at, index: true
            
            t.timestamps
        end

        add_reference :cloud_help_catalog_ticket_categories, :cloud_help_accounts, foreign_key: true, index: {name: "help_catalog_ticket_categories_accounts"}
        add_index :cloud_help_catalog_ticket_categories, :ancestry
    end
end
