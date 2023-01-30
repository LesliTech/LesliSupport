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


RSpec.describe "POST:/help/workflows.json", type: :request do
    include_context "request user authentication"
    # test cases

    it "should be able to create a workflow only with name" do
        new_workflow_params = {
            name: Faker::Lorem.word,
        }

        post("/help/workflows.json", params: {
            workflow: new_workflow_params
        })

        expect_response_with_successful

        # shared_expects validates the response body with the given arguments
        shared_expects(response_body, new_workflow_params, [
            { key: "id", expected_type: "integer" },
            { key: "name", expected_type: "string", expected_value: new_workflow_params[:name] }
        ])
    end

    it "should respond with error if params are empty" do
        new_workflow_params = {}        

        post("/help/workflows.json", params: {
            workflow: new_workflow_params
        })

        expect_response_with_error
    end

end
