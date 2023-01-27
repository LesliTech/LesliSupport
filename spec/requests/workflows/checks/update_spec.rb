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


RSpec.describe "PUT:/help/workflows/:workflow_id/checks/:check_id.json", type: :request do
    include_context "request user authentication"
    # test cases

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
            final_status_id: new_workflow.statuses[1].id
        } 
        
        check = CloudHelp::Workflow.find(new_workflow.id).checks.new(check_params)
        check.save!
        check
    end

    it "is expected to update check info" do

        new_check_params = {
            name: Faker::Lorem.word,
            active: true,
            user_type: ["any", "creator", "main"].sample,
            initial_status_id: new_workflow.statuses[0].id,
            final_status_id: new_workflow.statuses[1].id
        }

        put("/help/workflows/#{new_workflow.id}/checks/#{new_check.id}.json", params: {
            workflow_check: new_check_params
        })

        puts response_body
        expect_response_with_successful

        # shared_expects validates the response body with the given arguments
        shared_expects(response_body, new_check_params, [
            { key: "id", expected_type: "integer" },
            { key: "active", expected_type: "boolean", expected_value: new_check_params[:active] },
            { key: "name", expected_type: "string", expected_value: new_check_params[:name] },
            { key: "initial_status_id", expected_type: "integer", expected_value: new_check_params[:initial_status_id] },
            { key: "final_status_id", expected_type: "integer", expected_value: new_check_params[:final_status_id] },
            { key: "user_type", expected_type: "string", expected_value: new_check_params[:user_type] },
            { key: "created_at", expected_type: "string" },
            { key: "updated_at", expected_type: "string" },
            { key: "cloud_help_workflows_id", expected_type: "integer", expected_value: new_workflow.id }
        ])
    end

    it "is expected to respond with not found if id is not valid" do
        new_check_params = {
            name: Faker::Lorem.word,
            active: true,
            user_type: ["any", "creator", "main"].sample,
            initial_status_id: new_workflow.statuses[0].id,
            final_status_id: new_workflow.statuses[1].id
        }

        put("/help/workflows/#{new_workflow.id}/checks/#{new_check.id + 1 }.json", params: {
            workflow_check: new_check_params
        })

        expect_response_with_not_found

    end

    it "is expected to respond with not error if params are empty" do
        new_check_params = {}

        put("/help/workflows/#{new_workflow.id}/checks/#{new_check.id}.json", params: {
            workflow_check: new_check_params
        })

        expect_response_with_error

    end

  

end
