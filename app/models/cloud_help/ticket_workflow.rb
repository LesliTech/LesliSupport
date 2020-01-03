module CloudHelp
    class TicketWorkflow < ApplicationRecord
        belongs_to :ticket_type, class_name: "CloudHelp::TicketType", foreign_key: "cloud_help_ticket_types_id" 
        belongs_to :ticket_category, class_name: "CloudHelp::TicketCategory", foreign_key: "cloud_help_ticket_categories_id" 
        belongs_to :sla, class_name: "CloudHelp::Sla", foreign_key: "cloud_help_slas_id"

        after_update :verify_default_workflow
        
        has_many(
            :details,
            inverse_of: :ticket_workflow,
            class_name: "CloudHelp::TicketWorkflow::Detail",
            foreign_key: "cloud_help_ticket_workflows_id",
            dependent: :delete_all
        )

        validates :cloud_help_slas_id, presence: true
        accepts_nested_attributes_for :details

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
                :sla
            ).select(
                "cloud_help_ticket_workflows.id",
                "cloud_help_ticket_workflows.default",
                "cloud_help_ticket_workflows.created_at",
                "cloud_help_ticket_workflows.updated_at",
                "cloud_help_ticket_types.name as ticket_type_name",
                "cloud_help_ticket_categories.name as ticket_category_name",
                "cloud_help_ticket_categories.id as ticket_category_id",
                "cloud_help_slas.name as sla_name"
            ).where(
                "cloud_help_slas.cloud_help_accounts_id = #{account.id}"
            ).order(
                "ticket_type_name asc",
                "ticket_category_name asc"
            )
            result.each do |ticket_workflow|
                ticket_workflow.ticket_category_name = TicketCategory.find(ticket_workflow.ticket_category_id).full_path
            end
            result
        end

        def full_workflow
            data = {}
            nodes = TicketWorkflow::Detail.joins(
                :ticket_workflow
            ).joins(
                :ticket_state
            ).select(
                "cloud_help_ticket_workflow_details.id",
                "cloud_help_ticket_states.initial",
                "cloud_help_ticket_states.final",
                "cloud_help_ticket_workflow_details.next_states",
                "cloud_help_ticket_states.id as ticket_state_id",
                "cloud_help_ticket_states.name as ticket_state_name"
            ).where(
                "cloud_help_ticket_workflows.id = #{id}"
            )
            nodes.each do |node|
                node = node.attributes
                node["visited"] = false
                data[node["ticket_state_id"]] = node
            end
            {
                ticket_category_name: TicketCategory.find(ticket_category.id).full_path,
                ticket_type_name: ticket_type.name,
                cloud_help_slas_id: cloud_help_slas_id,
                default: default,
                sla_name: sla.name,
                details: data
            }
        end

        def replace_workflow(account, new_workflow)
            begin
                details.where(
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
                        details.where(id: node[:id]).update( next_states: node[:next_states] )
                    else
                        details.create(
                            cloud_help_ticket_states_id: node[:ticket_state_id],
                            next_states: node[:next_states]
                        )
                    end
                end
            rescue ActiveRecord::InvalidForeignKey
                errors.add(:base, :foreign_key_prevents_destruction)
                false
            end
        end

        def self.create_default_workflow(ticket_type, ticket_category)

            initial_state = TicketState.find_by(initial: true)
            final_state = TicketState.find_by(final: true)
            default_sla = Sla.find_by(default: true)

            if ticket_type
                TicketCategory.all.each do |category|
                    TicketWorkflow.create!(
                        sla: default_sla,
                        ticket_type: ticket_type,
                        ticket_category: category,
                        details_attributes: [
                            {
                                ticket_state: initial_state,
                                next_states: "#{final_state.id}"
                            },{
                                ticket_state: final_state
                            }
                        ]
                    )
                end
            elsif ticket_category
                TicketType.all.each do |type|
                    TicketWorkflow.create!(
                        sla: default_sla,
                        ticket_type:type,
                        ticket_category: ticket_category,
                        details_attributes: [
                            {
                                ticket_state: initial_state,
                                next_states: "#{final_state.id}"
                            },{
                                ticket_state: final_state
                            }
                        ]
                    )
                end
            end
        end

        def verify_default_workflow
            default_change = saved_changes["default"]
            return unless default_change
            
            if default_change[1]
                # default changed from false to true
                raise ActiveRecord::RecordInvalid, self unless TicketWorkflow.where(default: true).where.not(id: id).update(default: false)
            end
        end

    end
end
