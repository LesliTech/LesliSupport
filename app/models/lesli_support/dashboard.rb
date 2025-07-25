
module LesliSupport
    class Dashboard < Lesli::Shared::Dashboard
        self.table_name = "lesli_support_dashboards"
        belongs_to :account

        COMPONENTS = %i[ticket_count ticket_priority ticket_category]
    end
end
