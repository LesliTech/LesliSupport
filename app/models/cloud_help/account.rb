module CloudHelp
    class Account < ApplicationRecord
        belongs_to :account, class_name: "::Account", foreign_key: "id"
        has_many :ticket, foreign_key: 'cloud_help_accounts_id'
        has_many :ticket_categories, foreign_key: 'cloud_help_accounts_id'
        has_many :ticket_priorities, foreign_key: 'cloud_help_accounts_id'
        has_many :ticket_states, foreign_key: 'cloud_help_accounts_id'
        has_many :ticket_types, foreign_key: 'cloud_help_accounts_id'
    end
end
