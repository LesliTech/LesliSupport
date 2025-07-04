
module LesliSupport
    class Dashboard < Lesli::Shared::Dashboard
        self.table_name = "lesli_support_dashboards"

        belongs_to :account

        def self.initialize_dashboard(account) 
            super(self, account, [])
        end
    end
end
