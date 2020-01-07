module CloudHelp
    class TicketWorkflow::Detail < ApplicationRecord
        belongs_to :ticket_workflow, inverse_of: :details, class_name: "CloudHelp::TicketWorkflow", foreign_key: "cloud_help_ticket_workflows_id"
        belongs_to :ticket_state, class_name: "CloudHelp::TicketState", foreign_key: "cloud_help_ticket_states_id"
        has_many :ticket_details, class_name: "CloudHelp::Ticket::Detail", foreign_key: "cloud_help_ticket_details_id"
        
        def follow_up_states
            return [] unless next_states
            
            ids = next_states.split('|').map(&:to_i)
            ticket_workflow.details.where(cloud_help_ticket_states_id: ids).map do |workflow_detail|
                ticket_state = workflow_detail.ticket_state
                {
                    id: ticket_state.id,
                    name: ticket_state.name,
                    workflow_detail_id: workflow_detail.id
                }
            end
        end

    end
end
