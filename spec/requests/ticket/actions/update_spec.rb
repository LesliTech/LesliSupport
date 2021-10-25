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

RSpec.describe "PUT:/help/tickets/:ticket_id/actions/:id.json with a valid request", type: :request do
    include_context "user authentication"

    before(:all) do
        @ticket = build_random_ticket(@user)
        @ticket_action = build_random_ticket_action(@user, @ticket)
        @params = build_ticket_action_params(@user)

        put("/help/tickets/#{@ticket.id}/actions/#{@ticket_action.id}.json", params: @params)
    end

    include_examples "successful standard json response"

    it "is expected that the response has an the same params as the request" do
        expect(@response_body["data"]["id"]).not_to eq(nil)
        
        expect(@response_body["data"]["id"]).to eq(@ticket_action.id)
        expect(@response_body["data"]["complete"]).to eq(@params[:ticket_action][:complete])
        expect(@response_body["data"]["instructions"]).to eq(@params[:ticket_action][:instructions])
        expect(@response_body["data"]["group"]).to eq(@params[:ticket_action][:group])
    end
end 
