class CreateCloudHelpSlaActions < ActiveRecord::Migration[6.0]
  def change
    create_table :cloud_help_sla_actions do |t|

      t.timestamps
    end
  end
end
