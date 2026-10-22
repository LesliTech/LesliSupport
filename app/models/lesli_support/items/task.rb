module LesliSupport
    module Items
        class Task < Lesli::Items::Task
            self.table_name = "lesli_support_items_tasks"

            belongs_to :account, class_name: "LesliSupport::Account"
        end
    end
end
