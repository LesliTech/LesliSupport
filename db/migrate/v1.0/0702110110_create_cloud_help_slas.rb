class CreateCloudHelpSlas < ActiveRecord::Migration[6.0]
    def change
        create_table :cloud_help_slas do |t|
            t.string    :name
            t.integer   :expected_response_time
            t.integer   :expected_resolution_time
            t.float     :price_per_hour
            t.json      :body
            t.json      :provider_repercussions
            t.json      :client_repercussions
            t.json      :exceptions
            t.boolean   :default, default: false

            # Main user
            t.bigint    :user_main_id

            # acts_as_paranoid
            t.datetime :deleted_at, index: true

            t.timestamps
        end
        add_reference   :cloud_help_slas, :cloud_help_accounts, foreign_key: true
        add_reference   :cloud_help_slas, :users, foreign_key: true, index: { name: "help_slas_users" }
        add_foreign_key :cloud_help_slas, :users, column: :user_main_id

        add_reference   :cloud_help_slas,   :cloud_help_workflow_statuses,  foreign_key: true, index: { name: "help_slas_workflow_statuses" }
        add_reference   :cloud_help_tickets,:cloud_help_slas,               foreign_key: true, index: {name: "help_tickets_slas"}
    end
end
