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
                },
                {
                    number: 3,
                    name: "finished",
                    status_type: "completed_successfully",
                    next_statuses: ""
                }
            ]
        } 
        

        workflow = CloudHelp::Workflow.new(workflow_params)
        workflow.save!
        workflow
    end

    it 'is expected to respond with all the workflows' do
        get '/help/workflows.json'
        
        # shared examples
        expect_response_with_successful

        # shared specs
        expect(@response_body_data).to be_a(Object)
        expect(response_body["workflows"][0]).to be_a(Object)

        expect(response_body["workflows"][0]).to have_key("id")
        expect(response_body["workflows"][0]["id"]).to be_a(Integer)

        expect(response_body["workflows"][0]).to have_key("name")
        expect(response_body["workflows"][0]["name"]).to be_a(String)
        expect(response_body["workflows"][0]["name"]).to be_eql(new_workflow.name)

        expect(response_body["workflows"][0]).to have_key("default")
        expect(response_body["workflows"][0]["default"]).to be_in([true, false])
        expect(response_body["workflows"][0]["default"]).to be_eql(new_workflow.default)

        expect(response_body["workflows"][0]).to have_key("created_at")
        expect(response_body["workflows"][0]["created_at"]).to be_a(String)

        expect(response_body["workflows"][0]).to have_key("updated_at")
        expect(response_body["workflows"][0]["updated_at"]).to be_a(String)

        expect(response_body["workflows"][0]).to have_key("checks")
        expect(response_body["workflows"][0]["checks"]).to be_a(Object)

        expect(response_body["workflows"][0]["checks"]).to have_key("initial_status")
        expect(response_body["workflows"][0]["checks"]["initial_status"]).to be_a(Object)

        expect(response_body["workflows"][0]["checks"]["initial_status"]).to have_key("passed")
        expect(response_body["workflows"][0]["checks"]["initial_status"]["passed"]).to be_in([true, false])

        expect(response_body["workflows"][0]["checks"]).to have_key("floating_statuses")
        expect(response_body["workflows"][0]["checks"]["floating_statuses"]).to be_a(Object)

        expect(response_body["workflows"][0]["checks"]["floating_statuses"]).to have_key("passed")
        expect(response_body["workflows"][0]["checks"]["floating_statuses"]["passed"]).to be_in([true, false])

        expect(response_body["workflows"][0]["checks"]).to have_key("missing_transitione")
        expect(response_body["workflows"][0]["checks"]["missing_transitione"]).to be_a(Object)

        expect(response_body["workflows"][0]["checks"]["missing_transitione"]).to have_key("passed")
        expect(response_body["workflows"][0]["checks"]["missing_transitione"]["passed"]).to be_in([true, false])

        expect(response_body["workflows"][0]["checks"]).to have_key("associated")
        expect(response_body["workflows"][0]["checks"]["associated"]).to be_a(Object)

        expect(response_body["workflows"][0]["checks"]["associated"]).to have_key("passed")
        expect(response_body["workflows"][0]["checks"]["associated"]["passed"]).to be_in([true, false])

        expect(response_body["workflows"][0]).to have_key("connected_to")
        expect(response_body["workflows"][0]["connected_to"]).to be_a(Array)


    end
end
