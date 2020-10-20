class CreateCloudHelpSlas < ActiveRecord::Migration[6.0]
    def change
        create_table :cloud_help_slas do |t|
            t.string    :name
            t.text      :body
            t.integer   :expected_response_time
            t.integer   :expected_resolution_time
            t.text      :provider_repercussions
            t.text      :exceptions
            t.boolean   :default, default: false

            # acts_as_paranoid
            t.datetime :deleted_at, index: true

            t.timestamps
        end
        add_reference :cloud_help_slas, :cloud_help_accounts, foreign_key: true
    end
end
