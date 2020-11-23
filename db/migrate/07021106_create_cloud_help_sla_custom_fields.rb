class CreateCloudHelpSlaCustomFields < ActiveRecord::Migration[6.0]
    def change
        table_base_structure = JSON.parse(File.read(Rails.root.join("db","structure","00000301_custom_fields.json")))
        create_table :cloud_help_sla_custom_fields do |t|
            table_base_structure.each do |column|
                t.send(
                    column["type"].parameterize.underscore.to_sym,
                    column["name"].parameterize.underscore.to_sym
                )
            end
            t.timestamps
        end
        add_reference :cloud_help_sla_custom_fields, :users, foreign_key: true
        add_reference :cloud_help_sla_custom_fields, :cloud_help_slas, foreign_key: true, index: { name: "help_sla_custom_fields_slas" }
    end
end
