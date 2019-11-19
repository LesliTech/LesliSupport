module CloudHelp
    class TicketState::Assignment < ApplicationRecord
        belongs_to :ticket_state, class_name: "CloudHelp::TicketState", foreign_key: "cloud_help_ticket_states_id"
        belongs_to :ticket_type, class_name: "CloudHelp::TicketType", foreign_key: "cloud_help_ticket_types_id" 
        belongs_to :ticket_category, class_name: "CloudHelp::TicketCategory", foreign_key: "cloud_help_ticket_categories_id" 
    end
end
