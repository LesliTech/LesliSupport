module CloudHelp
=begin

Lesli

Copyright (c) 2020, Lesli Technologies, S. A.

All the information provided by this website is protected by laws of Guatemala related 
to industrial property, intellectual property, copyright and relative international laws. 
Lesli Technologies, S. A. is the exclusive owner of all intellectual or industrial property
rights of the code, texts, trade mark, design, pictures and any other information.
Without the written permission of Lesli Technologies, S. A., any replication, modification,
transmission, publication is strictly forbidden.
For more information read the license file including with this software.

LesliCloud - Your Smart Business Assistant

Powered by https://www.lesli.tech
Building a better future, one line of code at a time.

@author   Carlos Hermosilla
@license  Propietary - all rights reserved.
@version  0.1.0-alpha
@description Model for ticket workflow details. Each detail is accessed only through its *workflow*, and
    represents one *ticket* *state*. Each detail also contains information about transitions to
    other details
=end
    class TicketWorkflow::Detail < ApplicationRecord
        belongs_to :ticket_workflow, inverse_of: :details, class_name: "CloudHelp::TicketWorkflow", foreign_key: "cloud_help_ticket_workflows_id"
        belongs_to :ticket_workflow_state, class_name: "CloudHelp::TicketWorkflowState", foreign_key: "cloud_help_ticket_workflow_states_id"
        has_many :ticket_details, class_name: "CloudHelp::Ticket::Detail", foreign_key: "cloud_help_ticket_details_id"
        
=begin
@return [Array] List of hashes. Each hash represents an transition from this detail to
    another one.
@description Returns a list of all the transitions from the *state* associated to this detail,
    to other details. The fields of each hash are *id* of the detail, *name* of the state and
    *id* of the workflow detail
@example
    workflow = CloudHelp::TicketWorkflow.find(1)
    initial_detail = workflow.details.where(ticket_state: CloudHelp::TicketState.initial_state)
    transitions = initial_detail.follow_up_states
    puts transitions.to_json # will print something like
    #[
    #    {
    #        "id": 2,                     # The id of the state
    #        "name": "closed",            # The name of the state
    #        "workflow_detail_id": 34     # the id of the workflow detail
    #    }
    #]
=end
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
