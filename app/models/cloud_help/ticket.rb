module CloudHelp
    class Ticket  < ApplicationRecord

        belongs_to :account, class_name: 'CloudHelp::Account', foreign_key: 'cloud_help_accounts_id'
        
        has_many :discussions, foreign_key: 'cloud_help_tickets_id'
        has_many :actions, foreign_key: 'cloud_help_tickets_id'
        has_many :files, foreign_key: 'cloud_help_tickets_id'

        has_one :detail, inverse_of: :ticket, autosave: true, foreign_key: 'cloud_help_tickets_id'
        accepts_nested_attributes_for :detail

        def set_workflow
            detail.workflow = TicketWorkflow.find_by(
                ticket_type: detail.type,
                ticket_category: detail.category,
                ticket_state: TicketState.initial_state
            )
        end

        def detailed_info
            return attributes
        end

        def self.detailed_info(help_account)
            tickets = help_account.tickets.all

            tickets.map do |ticket|
                detail = ticket.detail
                ticket.attributes.merge({
                    subject: detail.subject,
                    type: detail.type.name,
                    state: detail.workflow.ticket_state.name,
                    category: detail.category.name,
                    priority: detail.priority.name
                })
            end
        end
        

    end
end
