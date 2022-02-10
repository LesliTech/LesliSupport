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



RSpec.describe "DELETE:/help/catalog/ticket_workspaces with a valid request and a non default ticket", type: :request do
    include_context "user authentication"


    it "is expected that the record will be deleted from the database" do

        # Setup
        @workspace = build_random_workspace(@user)

        # Request
        delete("/help/catalog/ticket_workspaces/#{@workspace.id}.json")

        # Checks
        expect_json_response_successful
        expect(@user.account.help.ticket_workspaces.find_by_id(@workspace.id)).to eq(nil)
    end
end

RSpec.describe "DELETE:/help/catalog/ticket_workspaces with a valid request and a default ticket", type: :request do
    include_context "user authentication"


    it "is expected that the record will not be deleted from the database" do

        # Setup
        @workspace = build_random_workspace(@user, default: true)

        # Request
        delete("/help/catalog/ticket_workspaces/#{@workspace.id}.json")

        # Checks
        expect_json_response_error
        expect(@user.account.help.ticket_workspaces.find_by_id(@workspace.id)).not_to eq(nil)
    end
end
