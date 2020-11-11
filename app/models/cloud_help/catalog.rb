module CloudHelp
    module Catalog
        def self.table_name_prefix
            'cloud_help_catalog_'
        end

        def self.initialize_data(account)
            # Initializing Ticket Sources, default source is CloudHelp
            Catalog::TicketSource.create!(name: "CloudHelp", account: account)

            # Initializing Ticket Categories
            Catalog::TicketCategory.create!(name: "User Management", account: account)
            Catalog::TicketCategory.create!(name: "Role Management", account: account)
            Catalog::TicketCategory.create!(name: "Account Management", account: account)

            # Initializing Ticket Priorities
            Catalog::TicketPriority.create!(name: "Lowest", weight: 1, account: account)
            Catalog::TicketPriority.create!(name: "Low", weight: 10, account: account)
            Catalog::TicketPriority.create!(name: "Medium", weight: 100, account: account)
            Catalog::TicketPriority.create!(name: "High", weight: 1000, account: account)
            Catalog::TicketPriority.create!(name: "Very High", weight: 5000, account: account)
            Catalog::TicketPriority.create!(name: "Urgent", weight: 10000, account: account)
            Catalog::TicketPriority.create!(name: "Highest", weight: 100000, account: account)

            # Initializing Ticket Types
            Catalog::TicketType.create!(name: "Change Request", account: account)
            Catalog::TicketType.create!(name: "Bug", account: account)
            Catalog::TicketType.create!(name: "General Question", account: account)
            Catalog::TicketType.create!(name: "New Development", account: account)
        end
    end
end
