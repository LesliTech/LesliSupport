
module LesliSupport
    class Dashboard < Lesli::Shared::Dashboard
        self.table_name = "lesli_support_dashboards"

        belongs_to :account

        has_many :components, inverse_of: :dashboard, autosave: true, dependent: :destroy
        accepts_nested_attributes_for :components, allow_destroy: true

        def self.initialize_dashboard(account) 
            super(self, account, [])
        end
    end
end
