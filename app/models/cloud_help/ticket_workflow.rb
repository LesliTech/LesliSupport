module CloudHelp
    class TicketWorkflow < CloudObject::ObjectWorkflow
        belongs_to :account, class_name: "CloudHelp::Account", foreign_key: "cloud_help_accounts_id"
        belongs_to :workflow, class_name: "CloudHelp::Workflow", foreign_key: "cloud_help_workflows_id"
        
        belongs_to :ticket_category, class_name: "CloudHelp::TicketCategory", foreign_key: "cloud_help_ticket_categories_id"
        belongs_to :ticket_type, class_name: "CloudHelp::TicketType", foreign_key: "cloud_help_ticket_types_id"

        def self.associations 
            [
                {
                    name: "ticket_category",
                    class: "CloudHelp::TicketCategory",
                    key: :cloud_help_ticket_categories_id,
                    identifier: :name
                },{
                    name: "ticket_type",
                    class: "CloudHelp::TicketType",
                    key: :cloud_help_ticket_types_id,
                    identifier: :name
                }
            ]
        end
    end
end
