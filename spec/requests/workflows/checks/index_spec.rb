=begin

Copyright (c) 2023, all rights reserved.

All the information provided by this platform is protected by international laws related  to
industrial property, intellectual property, copyright and relative international laws.
All intellectual or industrial property rights of the code, texts, trade mark, design,
pictures and any other information belongs to the owner of this platform.

Without the written permission of the owner, any replication, modification,
transmission, publication is strictly forbidden.

For more information read the license file including with this software.

// · ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~
// ·

=end

require "lesli_request_helper"

RSpec.describe 'GET:/help/workflows.json', type: :request do
    include_context "request user authentication"

    let!(:new_workflow) do

        workflow_params =  {
            account: @current_user.account,
            name: Faker::Lorem.word,
            deletion_protection: true,
            default: false,
            statuses_attributes: [
                {
                    number: 1,
                    name: "created",
                    status_type: "initial",
                    next_statuses: ""
                },
                {
                    number: 2,
                    name: "confirmed",
                    status_type: "normal",
                    next_statuses: ""
                }
            ]
        } 
        
        workflow = CloudHelp::Workflow.new(workflow_params)
        workflow.save!
        workflow
    end

    let!(:new_check) do

        check_params =  {
            name: Faker::Lorem.word,
            active: true,
            user_type: ["any", "creator", "main"].sample,
            initial_status_id: new_workflow.statuses[0].id,
            final_status_id: new_workflow.statuses[1].id,
            roles_id: @current_user.roles.first.id,
            users_id: @current_user.id
        } 
        
        check = CloudHelp::Workflow.find(new_workflow.id).checks.new(check_params)
        check.save!
        check
    end

    it 'is expected to respond with all the workflows' do
        get "/help/workflows/#{new_workflow.id}/checks.json"
        
        # shared examples
        expect_response_with_successful

        # shared specs
        expect(@response_body_data).to be_a(Object)
        expect(response_body[0]).to be_a(Object)

        expect(response_body[0]).to have_key("id")
        expect(response_body[0]["id"]).to be_a(Integer)

        expect(response_body[0]).to have_key("name")
        expect(response_body[0]["name"]).to be_a(String)
        expect(response_body[0]["name"]).to be_eql(new_check.name)

        expect(response_body[0]).to have_key("user_type")
        expect(response_body[0]["user_type"]).to be_a(String)
        expect(response_body[0]["user_type"]).to be_eql(new_check.user_type)

        expect(response_body[0]).to have_key("initial_status_name")
        expect(response_body[0]["initial_status_name"]).to be_a(String)

        expect(response_body[0]).to have_key("final_status_name")
        expect(response_body[0]["final_status_name"]).to be_a(String)

        expect(response_body[0]).to have_key("active")
        expect(response_body[0]["active"]).to be_in([true, false])
        expect(response_body[0]["active"]).to be_eql(new_check.active)

        expect(response_body[0]).to have_key("role_id")
        expect(response_body[0]["role_id"]).to be_a(Integer)
        expect(response_body[0]["role_id"]).to be_eql(new_check.roles_id)

        expect(response_body[0]).to have_key("user_id")
        expect(response_body[0]["user_id"]).to be_a(Integer)
        expect(response_body[0]["user_id"]).to be_eql(new_check.users_id)

        expect(response_body[0]).to have_key("role_name")
        expect(response_body[0]["role_name"]).to be_a(String)

        expect(response_body[0]).to have_key("user_name")
        expect(response_body[0]["user_name"]).to be_a(String)

    end
end
