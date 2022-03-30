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

RSpec.describe "GET:/help/catalog/ticket_workspaces/:id with a valid request", type: :request do
    include_context "user authentication"


    it "is expected that the returned fields match the record on the database" do

        # Setup
        @workspace = build_random_workspace(@user)

        # Request
        get("/help/catalog/ticket_workspaces/#{@workspace.id}.json")

        # Checks
        expect_json_response_successful
        expect(response_data["id"]).to eq(@workspace.id)
        @workspace.attributes.each do |key, value|

            if response_data[key]
                next if ["created_at", "updated_at"].include? key

                expect(response_data[key]).to eq(value)
            end
        end
    end

end
