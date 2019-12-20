module CloudHelp
    class TicketWorkflow < ApplicationRecord
        belongs_to :ticket_state, class_name: "CloudHelp::TicketState", foreign_key: "cloud_help_ticket_states_id"
        belongs_to :ticket_type, class_name: "CloudHelp::TicketType", foreign_key: "cloud_help_ticket_types_id" 
        belongs_to :ticket_category, class_name: "CloudHelp::TicketCategory", foreign_key: "cloud_help_ticket_categories_id" 
        belongs_to :sla, class_name: "CloudHelp::Sla", foreign_key: "cloud_help_slas_id"
        has_many :ticket_details, class_name: "CloudHelp::Ticket::Detail", foreign_key: "cloud_help_ticket_workflows_id"

        validates :cloud_help_slas_id, presence: true

        DEFAULT_STATES = {
            initial: 1,
            final: 2
        }

        def self.detailed_info(account)
            result = TicketWorkflow.joins(
                :ticket_type
            ).joins(
                :ticket_category
            ).joins(
                :ticket_state
            ).joins(
                :sla
            ).select(
                "cloud_help_ticket_workflows.id",
                "cloud_help_ticket_workflows.created_at",
                "cloud_help_ticket_workflows.updated_at",
                "cloud_help_ticket_types.name as ticket_type_name",
                "cloud_help_ticket_categories.name as ticket_category_name",
                "cloud_help_ticket_categories.id as ticket_category_id",
                "cloud_help_slas.name as sla_name"
            ).where(
                "cloud_help_ticket_states.initial = true"
            ).where(
                "cloud_help_ticket_states.cloud_help_accounts_id = #{account.id}"
            ).order(
                "ticket_type_name asc",
                "ticket_category_name asc"
            )
            result.each do |ticket_workflow|
                self.set_category_path(ticket_workflow)
            end
            result
        end

        def full_workflow(account)
            data = {}
            workflow = TicketWorkflow.joins(
                :ticket_type
            ).joins(
                :ticket_category
            ).joins(
                :ticket_state
            ).joins(
                :sla
            ).select(
                "false as visited",
                "cloud_help_ticket_workflows.id",
                "cloud_help_ticket_states.initial",
                "cloud_help_ticket_states.final",
                "cloud_help_ticket_workflows.next_states",
                "cloud_help_ticket_states.id as ticket_state_id",
                "cloud_help_ticket_states.name as ticket_state_name",
                "cloud_help_ticket_types.name as ticket_type_name",
                "cloud_help_slas.name as sla_name",
                "cloud_help_slas.id as cloud_help_slas_id",
                "cloud_help_ticket_categories.name as ticket_category_name",
                "cloud_help_ticket_categories.id as ticket_category_id",
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
            TicketWorkflow.set_category_path(data[TicketWorkflow::DEFAULT_STATES[:initial]])
            data
        end

        def replace_workflow(account, new_workflow)
            begin
                workflow = TicketWorkflow.joins( :ticket_state ).where(
                    "cloud_help_ticket_states.cloud_help_accounts_id = #{account.id}"
                ).where(
                    "cloud_help_ticket_types_id = #{cloud_help_ticket_types_id}"
                ).where(
                    "cloud_help_ticket_categories_id = #{cloud_help_ticket_categories_id}"
                ).where(
                    "cloud_help_ticket_states_id != #{TicketWorkflow::DEFAULT_STATES[:initial]}"
                ).where(
                    "cloud_help_ticket_states_id != #{TicketWorkflow::DEFAULT_STATES[:final]}"
                ).destroy_all
                new_workflow.each do |node|
                    # created or closed
                    if (
                        node[:ticket_state_id] == TicketWorkflow::DEFAULT_STATES[:initial] ||
                        node[:ticket_state_id] == TicketWorkflow::DEFAULT_STATES[:final]
                    )
                        TicketWorkflow.find(node[:id]).update(
                            next_states: node[:next_states],
                            cloud_help_slas_id: node[:cloud_help_slas_id]
                        )
                    else
                        TicketWorkflow.create(
                            cloud_help_ticket_categories_id: cloud_help_ticket_categories_id,
                            cloud_help_ticket_types_id: cloud_help_ticket_types_id,
                            cloud_help_ticket_states_id: node[:ticket_state_id],
                            cloud_help_slas_id: node[:cloud_help_slas_id],
                            next_states: node[:next_states]
                        )
                    end
                end
            rescue ActiveRecord::InvalidForeignKey
                errors.add(:base, :foreign_key_prevents_destruction)
                false
            end
        end

        def follow_up_states
            unless next_states
                return []
            end
            ids = next_states.split('|').map(&:to_i)
            TicketWorkflow.joins(
                :ticket_state
            ).where(
                ticket_type: ticket_type,
                ticket_category: ticket_category,
                cloud_help_ticket_states_id: ids
            ).select(
                "cloud_help_ticket_workflows.id as workflow_id",
                "cloud_help_ticket_states.id",
                "cloud_help_ticket_states.name as state_name"
            ).order(
                "cloud_help_ticket_states.final asc",
                "cloud_help_ticket_states.name asc"
            )
        end

        private

        def self.set_category_path(workflow_node)
            workflow_node.ticket_category_name =  TicketCategory.find(workflow_node.ticket_category_id).full_path
        end
    end
end
