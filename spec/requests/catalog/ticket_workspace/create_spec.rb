=begin

Copyright (c) 2022, all rights reserved.

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

RSpec.describe 'POST:/help/catalog/ticket_workspaces', type: :request do
    include_context "request user authentication"

    it "is expected to create a new ticket workspace" do

        workspace_params = {
            name: Faker::Lorem.word,
            default: Faker::Boolean.boolean(true_ratio: 0.5)
        }

        post("/help/catalog/ticket_workspaces.json", params: {
            ticket_workspace: workspace_params
        })

        # shared examples
        expect_response_with_successful

        puts response_body

        # custom specs
        expect(response_body).to be_a(Object)

        expect(response_body).to have_key("id")
        expect(response_body["id"]).to be_a(Integer)

        expect(response_body).to have_key("name")
        expect(response_body["name"]).to be_a(String)
        expect(response_body["name"]).to eql(workspace_params[:name])

        expect(response_body).to have_key("default")
        expect(response_body["default"]).to be_in([true, false])
        expect(response_body["default"]).to eql(workspace_params[:default])

        expect(response_body).to have_key("cloud_help_accounts_id")
        expect(response_body["cloud_help_accounts_id"]).to be_a(Integer)

    end

    it "is expected to respond with error if workspace params are not sent " do

        post("/help/catalog/ticket_workspaces.json")
        # shared examples
        expect_response_with_error
    end

    it "is expected to respond with error if workspace params are empty" do

        workspace_params = {}

        post("/help/catalog/ticket_workspaces.json", params: {
            ticket_workspace: workspace_params
        })

        # shared examples
        expect_response_with_error
    end

    it "is expected to respond with error if name param is not sent" do

        workspace_params = {
            default: Faker::Lorem.word
        }

        post("/help/catalog/ticket_workspaces.json", params: {
            ticket_workspace: workspace_params
        })

        # shared examples
        expect_response_with_error
    end


end
