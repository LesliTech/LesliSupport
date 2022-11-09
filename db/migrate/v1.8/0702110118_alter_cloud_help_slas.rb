class AlterCloudHelpSlas < ActiveRecord::Migration[7.0]
    def change
        change_column(:cloud_help_slas, :body, :text)
        change_column(:cloud_help_slas, :exceptions, :text)
        change_column(:cloud_help_slas, :provider_repercussions, :text)
        change_column(:cloud_help_slas, :client_repercussions, :text)
    end
end
