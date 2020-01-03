module CloudHelp
  class Sla < ApplicationRecord

    belongs_to :account, class_name: 'CloudHelp::Account', foreign_key: 'cloud_help_accounts_id'
    has_many :ticket_workflows, class_name: 'CloudHelp::TicketWorkflow', foreign_key: 'cloud_help_slas_id'
    after_update :verify_default_sla

    def update(params)
        ticket_count = Sla.joins(
            "inner join cloud_help_ticket_workflows CHTW on CHTW.cloud_help_slas_id = cloud_help_slas.id"
        ).joins(
            "inner join cloud_help_ticket_workflow_details CHTWD on CHTWD.cloud_help_ticket_workflows_id = CHTW.id"
        ).joins(
            "inner join cloud_help_ticket_details CHTD on CHTD.cloud_help_ticket_workflow_details_id = CHTWD.id"
        ).joins(
            "inner join cloud_help_ticket_states CHTS on CHTWD.cloud_help_ticket_states_id = CHTS.id"
        ).where(
            "CHTS.final = false"
        ).count
        if ticket_count > 0
            errors.add(:base, :cannot_modify_while_ticket_in_progress)
            return false
        end

        super
    end

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
