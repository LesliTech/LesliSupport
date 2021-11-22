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
require "./engines/cloud_help/spec/requests/ticket/helper"

RSpec.configure do |config|
    config.include Requests::Ticket::Helper
end

RSpec.describe "GET:/help/tickets.json", type: :request do
    include_context "user authentication"

    it "is expected to respond with a list of tickets" do
        
        # Setup
        20.times do 
            build_random_ticket(@user)
        end

        # Request
        get "/help/tickets.json" 

        # Checks
        expect_json_response_successful
        expect(response_data["total_count"]).to eql(@user.account.help.tickets.count)
        expect(response_data["tickets"].length).to be >= 10 # Default response should either be 10 or 15
    end
end
