module LesliSupport
    module Items
        class Attachment < Lesli::Items::Attachment
            self.table_name = "lesli_support_items_attachments"

            belongs_to :account, class_name: "LesliSupport::Account"
        end
    end
end
