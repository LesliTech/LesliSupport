module CloudHelp
  class Sla < ApplicationRecord

    belongs_to :account, class_name: 'CloudHelp::Account', foreign_key: 'cloud_help_accounts_id'
    
  end
end
