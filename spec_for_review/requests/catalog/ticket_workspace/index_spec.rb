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

RSpec.describe "GET:help/catalog/ticket_workspaces.json", type: :request do
    include_context "user authentication"

    it "is expected to respond with a list of ticket workspaces" do
        
        # Setup
        20.times do 
            build_random_workspace(@user)
        end

        # Request
        get "/help/catalog/ticket_workspaces.json" 

        # Checks
        expect_json_response_successful
        expect(response_data["pagination"]["count_total"]).to eql(@user.account.help.ticket_workspaces.count)
        expect(response_data["records"].length).to be >= 10 # Default response should either be 10 or 15
    end
end
