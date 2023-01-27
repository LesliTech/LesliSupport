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

    it "is expected that the record has been removed from the database" do

        delete("/help/workflows/#{new_workflow.id}/checks/#{new_check.id}.json")

        # shared examples
        expect_response_with_successful
    end

    it "is expected to respond with not found when an invalid ID is sent" do
        # this ID does not exist, so should return with not found
        invalid_id = new_check.id + 1

        delete("/help/workflows/#{new_workflow.id}/checks/#{invalid_id}.json")
        
        # shared examples
        expect_response_with_not_found
    end

end
