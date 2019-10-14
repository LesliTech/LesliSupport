module CloudHelp
    class Account < ApplicationRecord
        belongs_to :account, class_name: "::Account", foreign_key: "id"
        has_many :ticket, foreign_key: 'cloud_help_accounts_id'
    end
end
