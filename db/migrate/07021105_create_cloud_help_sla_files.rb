class CreateCloudHelpSlaFiles < ActiveRecord::Migration[6.0]
  def change
    create_table :cloud_help_sla_files do |t|

      t.timestamps
    end
  end
end
