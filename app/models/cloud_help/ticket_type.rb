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
@description Model for ticket types

=end
    class TicketType < ApplicationRecord

        belongs_to :account, class_name: 'CloudHelp::Account', foreign_key: 'cloud_help_accounts_id'
        has_many :details, class_name: 'CloudHelp::Ticket::Detail', foreign_key: 'cloud_help_ticket_types_id'
        has_many :workflow_assignments, class_name: "CloudHelp::TicketWorkflowAssignment", foreign_key: "cloud_help_ticket_types_id", dependent: :destroy


        validates :name, presence: true

        after_save :assign_workflow_if_created

=begin
@return [Boolean] Wheter the ticket type was deleted or not
@description Attempts to delete this ticket type along with it's associated *workflow*.
    However, if there is a *ticket* associated to this *type*, it will not be deleted
    and an error will be added to the *errors* parameter
@example
    my_type = CloudHelp::TicketType.first
    if my_type.destroy
        puts "Ticket type successfully destroyed"
    else
        puts "Ticket type was not destroyed"
        puts my_type.errors.full_messages.to_sentence
    end
=end
        def destroy
            begin
                super
            rescue ActiveRecord::InvalidForeignKey
                errors.add(:base, :foreign_key_prevents_destruction)
                false
            end
        end

        protected

=begin
@return [Void]
@description Checks if the recently saved record is new, if it is new, creates one
    TicketWorkflowAssignment for each existent category, using the default workflow
@example
    my_type = CloudHelp::TicketType.new(name: "Complain")
    if my_type.save # This method is executed at the end of save.
        puts "Assignments have been created"
    else
        puts "Assignments were not created yet"
    end
=end
        def assign_workflow_if_created
            id_changes = saved_changes["id"]
            if id_changes
                default_workflow = Workflow.find_by(account: account, default: true)
                TicketCategory.where(account: account).all.each do |category|
                    TicketWorkflowAssignment.create(
                        account: account,
                        workflow: default_workflow,
                        ticket_category: category,
                        ticket_type: self,
                    )
                end
            end
        end
    end
end
