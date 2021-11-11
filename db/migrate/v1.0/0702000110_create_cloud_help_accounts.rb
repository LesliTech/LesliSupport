class CreateCloudHelpAccounts < ActiveRecord::Migration[6.0]
    def change
        create_table :cloud_help_accounts do |t|
            t.datetime :deleted_at, index: true
        end
        add_foreign_key :cloud_help_accounts, :accounts, column: :id
    end
end
