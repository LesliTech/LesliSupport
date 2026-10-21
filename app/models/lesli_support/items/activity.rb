module LesliSupport
    module Items
        class Activity < Lesli::Items::Activity
            self.table_name = "lesli_support_items_activities"

            belongs_to :account, class_name: "LesliSupport::Account"
        end
    end
end
