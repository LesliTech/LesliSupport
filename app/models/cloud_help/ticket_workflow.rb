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
@description Model for ticket workflows. Each workflow is associated to one type and one category,
    and has several details. Each one if these details is accessed only through this model, and
    represents one *ticket* *state*. Each detail also contains information about transitions to
    other details
=end
    class TicketWorkflow < ApplicationRecord
        belongs_to :account, class_name: 'CloudHelp::Account', foreign_key: 'cloud_help_accounts_id'
        
        has_many(
            :details,
            inverse_of: :ticket_workflow,
            class_name: "CloudHelp::TicketWorkflow::Detail",
            foreign_key: "cloud_help_ticket_workflows_id",
            dependent: :delete_all
        )

        accepts_nested_attributes_for :details

        after_update :verify_default_workflow

=begin
@param account [Account] Account from current user
@return [Array] Array of workflows. 
@description Retrieves and returns all workflows from an *Account*.
    Each workflow contains only the fields to be displayed in
    a table
@example
    account = current_user.account
    workflows = CloudHelp::TicketWorkflow.detailed_info(account)
=end
        def self.detailed_info(account)
            TicketWorkflow.where(
                cloud_help_accounts_id: account.id
            ).select(
                :id,            :default,
                :name,          :created_at,
                :updated_at
            )
        end

=begin
@return [Boolean] Wheter the workflow was deleted or not
@description Attempts to delete this workflow.
    However, if there is a *cloud_object* associated to this *workflow*, it 
    will not be deleted and an error will be added to the *errors* parameter
@example
    my_workflow = CloudHelp::TicketWorkflow.first
    if my_workflow.destroy
        puts "workflow successfully destroyed"
    else
        puts "workflow was not destroyed"
        puts my_workflow.errors.full_messages.to_sentence
    end
=end
        def destroy
            if default
                errors.add(:base, :cannot_delete_default_workflow)
                false
            else
                begin
                    super
                rescue ActiveRecord::InvalidForeignKey
                    errors.add(:base, :foreign_key_prevents_destruction)
                    false
                end
            end
        end

=begin
@return [Hash] Hash of containing the information of the workflow and its details. 
@description Returns a hash with information about the workflow (*SLA*, *category*, etc.)
    and all its *details* that contain the transitions between *states*
@example
    workflow = CloudHelp::TicketWorkflow.first.full_workflow
    responseWithSuccessful(workflow)
=end
        def full_workflow
            data = {}
            nodes = TicketWorkflow::Detail.joins(
                :ticket_workflow
            ).joins(
                :ticket_workflow_state
            ).select(
                "cloud_help_ticket_workflow_details.id",
                "cloud_help_ticket_workflow_states.initial",
                "cloud_help_ticket_workflow_states.final",
                "cloud_help_ticket_workflow_details.next_states",
                "cloud_help_ticket_workflow_states.id as workflow_state_id",
                "cloud_help_ticket_workflow_states.name as workflow_state_name"
            ).where(
                "cloud_help_ticket_workflows.id = #{id}"
            )

            nodes.each do |node|
                node = node.attributes
                node["visited"] = false
                data[node["workflow_state_id"]] = node
            end

            {
                name: name,
                default: default,
                created_at: created_at,
                updated_at: updated_at,
                details: data
            }
        end

=begin
@param account [Account] Account from current user
@param new_workflow [Hash] A hash containing all the information of the
    changes made to the workflow in the same format as the rails standard
@return [Boolean] Whether the workflow was successfully updated or not
@description Updates the workflow with new states and transitions. The detail 
    associated with the *final* *state* can never change. The detail associated
    with the *initial* *state* can only change it's transitions, and all other
    details are destroyed and reinserted in the database. If an error ocurrs,
    a message is added to the *errors* param of the workflow
@example
    workflow_data  = {
        ticket_workflow:{
            cloud_help_slas_id:1,
            "details_attributes:[
                {
                    id:1,
                    next_states:"4",
                    workflow_state_id:1
                },{
                    id:2,
                    next_states:null
                    workflow_state_id:2
                },{
                    id:14,
                    next_states:"2",
                    workflow_state_id:4
                }
            ]
        }
    }
    workflow = CloudHelp::TicketWorkflow.find(4)
    if workflow.replace_workflow(workflow_data)
        puts "Ticket workflow was successfully replaced"
    else
        puts "Ticket workflow was not replaced"
        puts workflow.errors.full_messages.to_sentence
    end
=end
        def replace_workflow(account, new_workflow)
            begin
                initial_state_id = TicketWorkflowState.initial_state(account).id
                final_state_id = TicketWorkflowState.final_state(account).id
                details.where(
                    "cloud_help_ticket_workflow_states_id != #{initial_state_id}"
                ).where(
                    "cloud_help_ticket_workflow_states_id != #{final_state_id}"
                ).destroy_all
                new_workflow.each do |node|
                    # created or closed
                    if node[:cloud_help_ticket_workflow_states_id] == initial_state_id || node[:cloud_help_ticket_workflow_states_id] == final_state_id
                        details.where(id: node[:id]).update(next_states: node[:next_states])
                    else
                        details.create(
                            cloud_help_ticket_workflow_states_id: node[:cloud_help_ticket_workflow_states_id],
                            next_states: node[:next_states]
                        )
                    end
                end
            rescue ActiveRecord::InvalidForeignKey
                errors.add(:base, :foreign_key_prevents_destruction)
                false
            end
        end

private

=begin
@return [void]
@description Checks if a workflow was changed to default. If it was, marks the previously
    default workflow as not detault. If it is unable to do it, raises an exception that
    triggers a rollback
=end
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
