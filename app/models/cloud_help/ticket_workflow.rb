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
    class TicketWorkflow < CloudObject::Workflow
        belongs_to :account, class_name: 'CloudHelp::Account', foreign_key: 'cloud_help_accounts_id'
        
        has_many(
            :details,
            inverse_of: :workflow,
            class_name: "CloudHelp::TicketWorkflow::Detail",
            foreign_key: "cloud_help_ticket_workflows_id",
            dependent: :delete_all
        )

        accepts_nested_attributes_for :details

    end
end
