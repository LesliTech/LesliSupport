class CreateCloudHelpTicketFiles < ActiveRecord::Migration[6.0]
  def change
    create_table :cloud_help_ticket_files do |t|

      t.timestamps
    end
  end
end
