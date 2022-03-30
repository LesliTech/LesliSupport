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
require "./engines/cloud_help/spec/requests/catalog/ticket_workspace/helper"

RSpec.configure do |config|
    config.include Requests::Catalog::TicketWorkspace::Helper
end

RSpec.describe "PUT:/help/catalog/ticket_workspaces with a valid request and a non default ticket", type: :request do
    include_context "user authentication"


    it "is expected that the record will be updated" do

        # Setup
        @workspace = build_random_workspace(@user)
        @params = workspace_params(@user)

        # Request
        put("/help/catalog/ticket_workspaces/#{@workspace.id}.json", params: @params)

        # Checks
        expect_json_response_successful
        expect(response_data["id"]).to eq(@workspace.id)
        @params.each do |key, value|
            expect(@params[:ticket_workspace][key.to_sym]).to eq(response_data[key])
        end
    end
end

RSpec.describe "PUT:/help/catalog/ticket_workspaces with a non default ticket updated to default", type: :request do
    include_context "user authentication"

    it "is expected that the record will be updated" do

        # Setup
        @workspace = build_random_workspace(@user)
        @params = workspace_params(@user, default: true)

        # Request
        put("/help/catalog/ticket_workspaces/#{@workspace.id}.json", params: @params)

        # Checks
        expect_json_response_successful
        expect(response_data["id"]).to eq(@workspace.id)
        @params.each do |key, value|
            expect(@params[:ticket_workspace][key.to_sym]).to eq(response_data[key])
            expect(@user.account.help.ticket_workspaces.where(default: true).where("id != ?", response_data["id"]).count).to eq(0)
        end
    end
end

RSpec.describe "PUT:/help/catalog/ticket_workspaces with a default ticket updated to non default", type: :request do
    include_context "user authentication"

    it "is expected that the record will not be updated" do

        # Setup
        @workspace = build_random_workspace(@user, default: true)
        @params = workspace_params(@user, default: false)

        # Request
        put("/help/catalog/ticket_workspaces/#{@workspace.id}.json", params: @params)

        # Checks
        expect_json_response_error
    end
end
