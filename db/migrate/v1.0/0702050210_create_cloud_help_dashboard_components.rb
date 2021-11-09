class CreateCloudHelpDashboardComponents < ActiveRecord::Migration[6.0]
    def change
        table_base_structure = JSON.parse(File.read(Rails.root.join("db","structure","00000502_dashboard_components.json")))
        create_table :cloud_help_dashboard_components do |t|
            table_base_structure.each do |column|
                t.send(
                    column["type"].parameterize.underscore.to_sym,
                    column["name"].parameterize.underscore.to_sym
                )
            end
            t.timestamps
        end
        
        add_reference :cloud_help_dashboard_components, :cloud_help_dashboards, foreign_key: true, index: { name: "help_dashboard_components_dashboards" }
    end
end
