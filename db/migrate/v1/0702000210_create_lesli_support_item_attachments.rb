class CreateLesliSupportItemAttachments < ActiveRecord::Migration[8.1]
    def change
        create_table_lesli_item_attachments_10(:lesli_support)
    end
end
