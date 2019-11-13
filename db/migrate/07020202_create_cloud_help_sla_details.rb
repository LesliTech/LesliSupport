class CreateCloudHelpSlaDetails < ActiveRecord::Migration[6.0]
    def change
        create_table :cloud_help_sla_details do |t|
            t.timestamps
        end
        add_reference :cloud_help_sla_details, :cloud_help_slas, foreign_key: true
    end
end
