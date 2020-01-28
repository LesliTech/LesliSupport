=begin

Lesli

Copyright (c) 2019, Lesli Technologies, S. A.

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

@author   LesliTech <hello@lesli.tech>
@author   Carlos Hermosilla
@license  Propietary - all rights reserved.
@version  GIT: 1.0.0 alpha

// · 
// · ~·~        ~·~        ~·~        ~·~        ~·~        ~·~        ~·~        ~·~        ~·~

=end
CloudHelp::Account.all.each do |account|
    initial_state = CloudHelp::WorkflowState.initial_state(account)
    final_state = CloudHelp::WorkflowState.final_state(account)
    default_sla = CloudHelp::Sla.find_by(account: account, default: true)

    workflow = CloudHelp::Workflow.create!(
        name: "Dummy Workflow",
        default: true,
        account: account,
        details_attributes: [
            {
                cloud_help_workflow_states_id: initial_state.id,
                next_states: "#{final_state.id}"
            },
            {
                cloud_help_workflow_states_id: final_state.id
            }
        ]
    )
end
