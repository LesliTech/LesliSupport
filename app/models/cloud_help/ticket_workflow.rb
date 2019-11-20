module CloudHelp
    class TicketWorkflow < ApplicationRecord
        belongs_to :ticket_state, class_name: "CloudHelp::TicketState", foreign_key: "cloud_help_ticket_states_id"
        belongs_to :ticket_type, class_name: "CloudHelp::TicketType", foreign_key: "cloud_help_ticket_types_id" 
        belongs_to :ticket_category, class_name: "CloudHelp::TicketCategory", foreign_key: "cloud_help_ticket_categories_id" 

        def self.detailed_info(account)
            TicketWorkflow.joins(
                :ticket_type
            ).joins(
                :ticket_category
            ).joins(
                :ticket_state
            ).select(
                "cloud_help_ticket_workflows.id",
                "cloud_help_ticket_workflows.created_at",
                "cloud_help_ticket_workflows.updated_at",
                "cloud_help_ticket_types.name as ticket_type_name",
                "cloud_help_ticket_categories.name as ticket_category_name"
            ).where(
                "cloud_help_ticket_states.initial = true"
            ).order(
                "ticket_type_name asc",
                "ticket_category_name asc"
            )
        end

        def full_workflow(account)
            data = {}
            workflow = TicketWorkflow.joins(
                :ticket_type
            ).joins(
                :ticket_category
            ).joins(
                :ticket_state
            ).select(
                "false as visited",
                "cloud_help_ticket_workflows.id",
                "cloud_help_ticket_states.initial",
                "cloud_help_ticket_states.final",
                "cloud_help_ticket_workflows.next_states",
                "cloud_help_ticket_states.id as ticket_state_id",
                "cloud_help_ticket_states.name as ticket_state_name",
                "cloud_help_ticket_types.name as ticket_type_name",
                "cloud_help_ticket_categories.name as ticket_category_name"
            ).where(
                "cloud_help_ticket_states.cloud_help_accounts_id = #{account.id}"
            ).where(
                "cloud_help_ticket_types.id = #{cloud_help_ticket_types_id}"
            ).where(
                "cloud_help_ticket_categories.id = #{cloud_help_ticket_categories_id}"
            )
            workflow.each do |node|
                data[node[:ticket_state_id]] = node
            end
            data
        end
    end
end
