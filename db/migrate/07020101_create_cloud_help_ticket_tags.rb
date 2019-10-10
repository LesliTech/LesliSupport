class CreateCloudHelpTicketTags < ActiveRecord::Migration[6.0]
    def change
    create_table :cloud_help_ticket_tags do |t|
        t.timestamps
    end
    add_reference :cloud_help_ticket_tags, :cloud_help_accounts, foreign_key: true
    end
end
