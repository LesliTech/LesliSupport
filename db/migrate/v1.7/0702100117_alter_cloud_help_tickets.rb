class AlterCloudHelpTickets < ActiveRecord::Migration[7.0]
    def change
        change_column(:cloud_help_tickets, :description, :text)
    end
end
