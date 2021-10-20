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

require "rails_helper"
require "spec_helper"
require "byebug"
require "faker"

require "./engines/cloud_help/spec/requests/ticket/helper"

RSpec.configure do |config|
    config.include Requests::Ticket::Helper
end

RSpec.describe "GET:/help/tickets/:ticket_id/actions.json with a valid request", type: :request do
    include_context "user authentication"

    before(:all) do
        @ticket = build_random_ticket(@user)
        @group_length = 4
        @groups = []
        2.times do |group_iter|
            group = Faker::Lorem.word
            @groups.push(group)

            @group_length.times do |action_iter|
                @ticket_action = build_random_ticket_action(@user, @ticket, group: group)
            end
        end

        get("/help/tickets/#{@ticket.id}/actions.json")
    end

    include_examples "successful standard json response"

    it "is expected that the response has an the same params as the request" do
        expect(@response_body["data"]).not_to eq(nil)

        @groups.each do |group|
            expect(@response_body["data"]).to have_key(group)
            expect(@response_body["data"][group].length).to eq(@group_length)
        end
    end
end 
