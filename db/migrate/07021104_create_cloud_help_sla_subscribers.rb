class CreateCloudHelpSlaSubscribers < ActiveRecord::Migration[6.0]
  def change
    create_table :cloud_help_sla_subscribers do |t|

      t.timestamps
    end
  end
end
