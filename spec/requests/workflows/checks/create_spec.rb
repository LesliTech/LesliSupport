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


RSpec.describe "POST:/help/workflows/:id/checks.json", type: :request do
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

    # test cases

    it "should be able to create a check for a workflow" do

        new_check_params = {
            name: Faker::Lorem.word,
            active: true,
            user_type: ["any", "creator", "main"].sample,
            initial_status_id: new_workflow.statuses[0].id,
            final_status_id: new_workflow.statuses[1].id
        }

        post("/help/workflows/#{new_workflow.id}/checks.json", params: {
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

    it "should be able to create a check for a workflow with custom user type" do

        new_check_params = {
            name: Faker::Lorem.word,
            user_type: "custom",
            initial_status_id: new_workflow.statuses[0].id,
            final_status_id: new_workflow.statuses[1].id,
            users_id: @current_user.id,
            roles_id: @current_user.roles.first.id,
            active: true
        }

        post("/help/workflows/#{new_workflow.id}/checks.json", params: {
            workflow_check: new_check_params
        })

        expect_response_with_successful

        # shared_expects validates the response body with the given arguments
        shared_expects(response_body, new_check_params, [
            { key: "id", expected_type: "integer" },
            { key: "active", expected_type: "boolean", expected_value: new_check_params[:active] },
            { key: "name", expected_type: "string", expected_value: new_check_params[:name] },
            { key: "initial_status_id", expected_type: "integer", expected_value: new_check_params[:initial_status_id] },
            { key: "final_status_id", expected_type: "integer", expected_value: new_check_params[:final_status_id] },
            { key: "user_type", expected_type: "string", expected_value: new_check_params[:user_type] },
            { key: "users_id", expected_type: "integer", expected_value: new_check_params[:users_id] },
            { key: "roles_id", expected_type: "integer", expected_value: new_check_params[:roles_id] },
            { key: "created_at", expected_type: "string" },
            { key: "updated_at", expected_type: "string" },
            { key: "cloud_help_workflows_id", expected_type: "integer", expected_value: new_workflow.id }
        ])
    end


    it "should respond with error if params are empty" do
        new_check_params = {}        

        post("/help/workflows/#{new_workflow.id}/checks.json", params: {
            workflow_check: new_check_params
        })

        expect_response_with_error
    end
    

end
