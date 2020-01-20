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

=begin
@param account [Account] Account from current user
@return [Array] Array of workflows. 
@description Retrieves and returns all workflows from an *Account*.
    Each workflow contains fields to be displayed in
    a table, including the *category* and *type* of the workflow, as well as the
    *SLA* associated to it
@example
    account = current_user.account
    workflows = CloudHelp::TicketWorkflow.detailed_info(account)
=end
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
                    ticket_state_id:1
                },{
                    id:2,
                    next_states:null
                    ticket_state_id:2
                },{
                    id:14,
                    next_states:"2",
                    ticket_state_id:4
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
                initial_state_id = TicketState.initial_state(account).id
                final_state_id = TicketState.final_state(account).id
                details.where(
                    "cloud_help_ticket_states_id != #{initial_state_id}"
                ).where(
                    "cloud_help_ticket_states_id != #{final_state_id}"
                ).destroy_all
                new_workflow.each do |node|
                    # created or closed
                    if node[:ticket_state_id] == initial_state_id || node[:ticket_state_id] == final_state_id
                        details.where(id: node[:id]).update(next_states: node[:next_states])
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

=begin
@param ticket_type [CloudHelp::TicketType] The type of the created workflow
@param ticket_category [CloudHelp::TicketCategory] The category of the created workflow
@return [void]
@description Creates a workflow associated to the *type* and *category* received.
    The new workflow is either a copy of the *default* *workflow*, or a *dummy* *workflow*
    A *dummy* *workflow* is a simple workflow that goes from the *created* *state* to the *closed* *state*.
    If either *ticket_type* or *ticket_category* is nil, all *types* or *categories* are used
@example
    CloudHelp::TicketWorkflow.create_default_workflow(
        CloudHelp::TicketType.first,
        CloudHelp::TicketCategory.first
    )
    # This will create a new workflow, with either the default transitions, or the dummy transitions, if
    # there is not default workflow
=end
        def self.create_default_workflow(ticket_type, ticket_category)
            default_workflow = TicketWorkflow.find_by(default: true)
            default_sla = Sla.find_by(default: true)

            if default_workflow
                details_attributes = []
                default_workflow.details.each do |detail|
                    details_attributes.push({
                        cloud_help_ticket_states_id: detail.cloud_help_ticket_states_id,
                        next_states: detail.next_states
                    })
                end

                if ticket_type
                    TicketCategory.all.each do |category|
                        TicketWorkflow.create!(
                            sla: default_sla,
                            ticket_type: ticket_type,
                            ticket_category: category,
                            details_attributes: details_attributes
                        )
                    end
                elsif ticket_category
                    TicketType.all.each do |type|
                        TicketWorkflow.create!(
                            sla: default_sla,
                            ticket_type: type,
                            ticket_category: ticket_category,
                            details_attributes: details_attributes
                        )
                    end
                end
            else
                create_dummy_workflow(ticket_type, ticket_category)
            end
        end

private

=begin
@param ticket_type [CloudHelp::TicketType] The type of the created workflow
@param ticket_category [CloudHelp::TicketCategory] The category of the created workflow
@return [void]
@description Creates a dummy workflow associated to the *type* and *category* received.
    A *dummy* *workflow* is a simple workflow that goes from the *created* *state* to the *closed* *state*.
@example
    CloudHelp::TicketWorkflow.create_default_workflow(
        CloudHelp::TicketType.first,
        CloudHelp::TicketCategory.first
    )
    # This will create a new dummy workflow only if there is not default workflow set
=end
        def create_dummy_workflow(ticket_type, ticket_category)
            initial_state = TicketState.initial_state(account)
            final_state = TicketState.final_state(account)
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
