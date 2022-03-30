=begin

Copyright (c) 2021, all rights reserved.

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



RSpec.describe "POST:/help/catalog/ticket_workspaces with a valid request and a non default ticket", type: :request do
    include_context "user authentication"


    it "is expected that the response has an the same values as the request" do

        # Setup
        @params = workspace_params(@user)

        # Request
        post("/help/catalog/ticket_workspaces.json", params: @params)

        # Checks
        expect_json_response_successful
        expect(response_data["id"]).not_to eq(nil)
        @params.each do |key, value|
            expect(@params[:ticket_workspace][key.to_sym]).to eq(response_data[key])
        end
    end
end

RSpec.describe "POST:/help/catalog/ticket_workspaces with a valid request and default ticket", type: :request do
    include_context "user authentication"


    it "is expected that the response has an the same values as the request" do

        # Setup
        @params = workspace_params(@user, default: true)

        # Request
        post("/help/catalog/ticket_workspaces.json", params: @params)

        # Checks
        expect_json_response_successful
        expect(response_data["id"]).not_to eq(nil)
        @params.each do |key, value|
            expect(@params[:ticket_workspace][key.to_sym]).to eq(response_data[key])
            expect(@user.account.help.ticket_workspaces.where(default: true).where("id != ?", response_data["id"]).count).to eq(0)
        end
    end
end
