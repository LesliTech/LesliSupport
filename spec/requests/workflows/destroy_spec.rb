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


RSpec.describe "DEL:/help/workflows/:id.json", type: :request do
    include_context "request user authentication"
    # test cases

    let!(:new_workflow) do

        workflow_params =  {
            account: @current_user.account,
            name: Faker::Lorem.word,
            deletion_protection: false,
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

    let!(:workflow_protected) do

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


    it "is expected that the record has been removed from the database" do

        delete("/help/workflows/#{new_workflow.id}.json")

        # shared examples
        expect_response_with_successful
    end

    it "is expected to respond with not found when an invalid ID is sent" do
        # this ID does not exist, so should return with not found
        invalid_id = workflow_protected.id + 1

        delete("/help/workflows/#{invalid_id}.json")
        
        # shared examples
        expect_response_with_not_found
    end


    it "is expected to respond with error for a workflow with deletion protection" do

        delete("/help/workflows/#{workflow_protected.id}.json")

        # shared examples
        expect_response_with_error
    end


end
