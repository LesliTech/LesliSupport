class CreateCloudHelpSlaCustomFields < ActiveRecord::Migration[6.0]
  def change
    create_table :cloud_help_sla_custom_fields do |t|

      t.timestamps
    end
  end
end
