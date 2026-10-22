module LesliSupport
    module Items
        class Discussion < Lesli::Items::Discussion
            self.table_name = "lesli_support_items_discussions"

            belongs_to :account, class_name: "LesliSupport::Account"
        end
    end
end
