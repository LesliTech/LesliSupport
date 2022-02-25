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



RSpec.describe "GET:/help/tickets/:id with a valid request", type: :request do
    include_context "user authentication"


    it "is expected that the returned fields match the record on the database" do

        # Setup
        @ticket = build_random_ticket(@user)

        # Request
        get("/help/tickets/#{@ticket.id}.json")

        # Checks
        expect_json_response_successful
        expect(response_data["id"]).to eq(@ticket.id)
        @ticket.attributes.each do |key, value|

            if response_data[key]
                next if ["created_at", "updated_at"].include? key

                if key == "deadline"
                    expect(LC::Date2.new(Time.iso8601(response_data["deadline"])).date_time.to_s).to eq(LC::Date2.new(value).date_time.to_s)
                    next
                end

                expect(response_data[key]).to eq(value)
            end
        end
    end

end
