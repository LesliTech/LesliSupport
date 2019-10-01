module CloudHelp
    class Account < ApplicationRecord
        belongs_to :account, class_name: "::Account", foreign_key: "id"
    end
end
