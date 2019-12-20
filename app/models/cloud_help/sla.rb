module CloudHelp
  class Sla < ApplicationRecord

    belongs_to :account, class_name: 'CloudHelp::Account', foreign_key: 'cloud_help_accounts_id'
    
    after_update :verify_default_sla

    def verify_default_sla
        default_change = saved_changes["default"]
        return unless default_change
        
        if default_change[1]
        # default changed from false to true
            raise ActiveRecord::RecordInvalid, self unless Sla.where(default: true).where.not(id: id).update(default: false)
        else
        # default changed from true to false
            unless Sla.where(default: true).where.not(id: id).count > 0
                errors.add(:base, :cannot_remove_default)
                raise ActiveRecord::RecordInvalid, self
                return false
            end
        end
    end
  end
end
