class AlterCloudHelpTickets < ActiveRecord::Migration[7.0]
    def change
        add_column :cloud_help_tickets, :started_at, :datetime
        add_column :cloud_help_tickets, :finished_at, :datetime
    end
end
