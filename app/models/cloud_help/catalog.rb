module CloudHelp
    module Catalog
        def self.table_name_prefix
            'cloud_help_catalog_'
        end

        def self.initialize_data(account)
            # Initializing Ticket Sources, default source is CloudHelp
            Catalog::TicketSource.create!(name: I18n.t("help.initial_values.catalog_ticket_sources.cloud_help"), account: account)

            # Initializing Ticket Categories
            Catalog::TicketCategory.create!(name: I18n.t("help.initial_values.catalog_ticket_categories.user_management"), account: account)
            Catalog::TicketCategory.create!(name: I18n.t("help.initial_values.catalog_ticket_categories.role_management"), account: account)
            Catalog::TicketCategory.create!(name: I18n.t("help.initial_values.catalog_ticket_categories.account_management"), account: account)

            # Initializing Ticket Priorities
            Catalog::TicketPriority.create!(name: I18n.t("help.initial_values.catalog_ticket_priorities.lowest"), weight: 1, account: account)
            Catalog::TicketPriority.create!(name: I18n.t("help.initial_values.catalog_ticket_priorities.low"), weight: 10, account: account)
            Catalog::TicketPriority.create!(name: I18n.t("help.initial_values.catalog_ticket_priorities.medium"), weight: 100, account: account)
            Catalog::TicketPriority.create!(name: I18n.t("help.initial_values.catalog_ticket_priorities.high"), weight: 1000, account: account)
            Catalog::TicketPriority.create!(name: I18n.t("help.initial_values.catalog_ticket_priorities.highest"), weight: 5000, account: account)

            # Initializing Ticket Types
            Catalog::TicketType.create!(name: I18n.t("help.initial_values.catalog_ticket_types.change_request"), account: account)
            Catalog::TicketType.create!(name: I18n.t("help.initial_values.catalog_ticket_types.bug"), account: account)
            Catalog::TicketType.create!(name: I18n.t("help.initial_values.catalog_ticket_types.general_question"), account: account)
            Catalog::TicketType.create!(name: I18n.t("help.initial_values.catalog_ticket_types.new_development"), account: account)
       
            # Initializer Ticket Workspaces
            Catalog::TicketWorkspace.create!(name: I18n.t("help.initial_values.catalog_ticket_workspaces.default"), default: true, account: account)
        end
    end
end
