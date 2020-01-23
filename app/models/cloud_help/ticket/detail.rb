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
@description Model for ticket detail. Each *ticket* has only one detail, that contains all relevant
    information (like *category*, *priority*, *source*, etc.). This is to maintaing the *cloud_help_tickets* table small. 
    The detail is not accessed directly, rather, it is accessed only through its *ticket*
=end
    class Ticket::Detail < ApplicationRecord
        include ActiveModel::Dirty
        
        belongs_to :ticket, inverse_of: :detail, foreign_key: "cloud_help_tickets_id"
        belongs_to :type, class_name: "CloudHelp::TicketType", foreign_key: "cloud_help_ticket_types_id"
        belongs_to :workflow_detail, class_name: "CloudHelp::TicketWorkflow::Detail", foreign_key: "cloud_help_ticket_workflow_details_id"
        belongs_to :priority, class_name: "CloudHelp::TicketPriority", foreign_key: "cloud_help_ticket_priorities_id"
        belongs_to :category, class_name: "CloudHelp::TicketCategory", foreign_key: "cloud_help_ticket_categories_id"
        belongs_to :source, class_name: "CloudHelp::TicketSource", foreign_key: "cloud_help_ticket_sources_id"
    end
end
