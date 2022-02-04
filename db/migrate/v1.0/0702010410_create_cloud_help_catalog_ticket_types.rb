class CreateCloudHelpCatalogTicketTypes < ActiveRecord::Migration[6.0]
    def change
        create_table :cloud_help_catalog_ticket_types do |t|
            t.string :name

            # acts_as_paranoid
            t.datetime :deleted_at, index: true
            
            t.timestamps
        end

        add_reference :cloud_help_catalog_ticket_types, :cloud_help_accounts, foreign_key: true, index: {name: "help_catalog_ticket_types_accounts"}
    end
end
