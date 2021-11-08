class CreateCloudHelpDashboards < ActiveRecord::Migration[6.0]
    def change
        table_base_structure = JSON.parse(File.read(Rails.root.join("db","structure","00000501_dashboards.json")))
        create_table :cloud_help_dashboards do |t|
            table_base_structure.each do |column|
                t.send(
                    column["type"].parameterize.underscore.to_sym,
                    column["name"].parameterize.underscore.to_sym
                )
            end
            t.timestamps
        end
        
        add_reference   :cloud_help_dashboards, :cloud_help_accounts,   foreign_key: true, index: { name: "help_dashboards_accounts" }
        add_reference   :cloud_help_dashboards, :users,                   foreign_key: true, index: { name: "help_dashboards_users" }
        add_reference   :cloud_help_dashboards, :roles,                   foreign_key: true, index: {name: "help_dashboards_roles"}
        add_foreign_key :cloud_help_dashboards, :users,                   column: :user_main_id
    end
end
