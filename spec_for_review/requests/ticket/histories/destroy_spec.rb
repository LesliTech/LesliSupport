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

require "rails_helper"
require "spec_helper"
require "byebug"
require "faker"

require "./engines/cloud_help/spec/requests/ticket/helper"

RSpec.configure do |config|
    config.include Requests::Ticket::Helper
end

RSpec.describe "DELETE:/help/tickets/:ticket_id/histories/:id.json with a valid request", type: :request do
    include_context "user authentication"

    before(:all) do
        @ticket = build_random_ticket(@user)
        @ticket_history = build_random_ticket_history(@user, @ticket)

        delete("/help/tickets/#{@ticket.id}/histories/#{@ticket_history.id}.json")
    end

    include_examples "successful standard json response"

    it "is expected that the record has been removed from the database" do
        expect(@user.account.help.tickets.find(@ticket.id).histories.find_by_id(@ticket_history.id)).to eq(nil)
    end
end 
