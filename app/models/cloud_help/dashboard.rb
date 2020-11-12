module CloudHelp
    class Dashboard < CloudObject::Dashboard
        belongs_to :account, class_name: "Account", foreign_key: "cloud_help_accounts_id"
        
        has_many :components, inverse_of: :dashboard, autosave: true, class_name: "Dashboard::Component", foreign_key: "cloud_help_dashboards_id", dependent: :destroy
        accepts_nested_attributes_for :components, allow_destroy: true

        def self.initialize_data(account)
            self.create!(
                account: account,
                name: "Default Dashboard",
                default: true,
                main: false,
                components_attributes: [
                    {
                        name: "Latest Tickets",
                        component_id: "new_tickets",
                        layout: 4,
                        index: 2,
                        query_configuration: {
                            filters: {},
                            pagination: {per_page: 6}
                        },
                        custom_configuration: {
                            arrangement: {}
                        }
                    },{
                        name: "My Tickets",
                        component_id: "my_tickets",
                        layout: 4,
                        index: 3,
                        query_configuration: {
                            filters: {},
                            pagination: {per_page: 6}
                        },
                        custom_configuration: {
                            arrangement: {}
                        }
                    },{
                        name: "Unassigned Tickets",
                        component_id: "unassigned_tickets",
                        layout: 4,
                        index: 4,
                        query_configuration: {
                            filters: {},
                            pagination: {per_page: 6}
                        },
                        custom_configuration: {
                            arrangement: {}
                        }
                    },{
                        name: "Tickets by Type",
                        component_id: "tickets_by_type",
                        layout: 6,
                        index: 0,
                        query_configuration: {
                            filters: {},
                            pagination: {}
                        },
                        custom_configuration: {
                            arrangement: {}
                        }
                    },{
                        name: "Tickets by Category",
                        component_id: "tickets_by_category",
                        layout: 6,
                        index: 0,
                        query_configuration: {
                            filters: {},
                            pagination: {}
                        },
                        custom_configuration: {
                            arrangement: {}
                        }
                    }
                ]
            )
        end
    end
end
