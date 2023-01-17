=begin
Copyright (c) 2022, all rights reserved.

All the information provided by this platform is protected by international laws related  to 
industrial property, intellectual property, copyright and relative international laws. 
All intellectual or industrial property rights of the code, texts, trade mark, design, 
pictures and any other information belongs to the owner of this platform.

Without the written permission of the owner, any replication, modification,
transmission, publication is strictly forbidden.

For more information read the license file including with this software.

// · ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~
// · 

=end
module CloudHelp
    class Account::Setting < ApplicationLesliRecord
        belongs_to :account, class_name: "CloudHelp::Account", foreign_key: "cloud_help_accounts_id"

        # @return [void]
        # @param help_account [CloudHelp::Account] The newly created help account
        # @description Initializes all the necessary settings for the engine to work without configuration. Those settings are: 
        #     tickets.assignments_role
        def self.initialize_data(help_account)
            help_account.settings.create!(key: "tickets_assignments_role", value: ::Role.find_by(name: "owner").id, protected: true)
        end

        # @return An array of hashes, each one containing the information of a setting
        # @param current_user [User] The user that made the request
        # @param query [Hash] A query object, that indicates filters and request configuration. This object is built by
        #     ApplicationLesliController using the helper: 'set_helpers_for_request'
        # @description Retrieves and returns the settings requested by the user specified by the **query** param. The settings are:
        #     tickets.assignments_role:         The role that a user has to have to be assigned to a ticket
        # @example 
        #     # Imagine the request query is ?filters[tickets]=true
        #     This will return the following settings: 
        #         - tickets.assignments_role
        def self.index(current_user, query)
            return current_user.account.help.settings
        end

        # @return [Hash] A hash containing the options for all settings selected by the **query** param
        # @param current_user [User] The user that made the request
        # @param query [Hash] A query object, that indicates filters and request configuration. This object is built by
        #     ApplicationLesliController using the helper: 'set_helpers_for_request'
        # @description Sets the options for the settings that the users wants to configure
        # @example
        #     # Imagine the user wants the ticket filters
        #     puts CloudHelp::Account::Setting.options(User.find(2), {filters: {tickets: "true"}})
        #     # This will display something like
        #     {
        #         assignment_roles: [
        #             {value: 1, text: "Owner"},
        #             {value: 2, text: "Admin"}
        #         ]
        #     }
        def self.options(current_user, query)

            role_options = current_user.account.roles.map {|role| {value: role.id, label: I18n.t("core.roles.column_enum_role_#{role.name}", default: role.name)} }

            return {
                roles: role_options
            }
        end

        def show(current_user, query)
            self
        end
    end
end
