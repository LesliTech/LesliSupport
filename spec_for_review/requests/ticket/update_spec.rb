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



RSpec.describe "PUT:/help/tickets/:id with a valid request", type: :request do
    include_context "user authentication"


    it "is expected that the fields of the ticket updated accordingly to the request" do

        # Setup
        @ticket = build_random_ticket(@user)
        @params = ticket_params(@user)

        # Request
        put("/help/tickets/#{@ticket.id}.json", params: @params)

        # Checks
        expect_json_response_successful
        expect(response_data["id"]).to eq(@ticket.id)
        @params.each do |key, value|
            expect(@params[:ticket][key.to_sym]).to eq(response_data[key])
        end
    end

end
