=begin
Copyright (c) 2023, all rights reserved.

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


# include helpers, configuration & initializers for request tests
require "lesli_request_helper"


RSpec.describe "DEL:/help/tickets/:id", type: :request, if: defined?(CloudHelp) do

    let(:create_ticket) { FactoryBot.create(:cloud_help_ticket )}

    include_context "request user authentication"

    # test cases
    it "is expected to delete a ticket" do

        new_ticket = create_ticket

        delete("/help/tickets/#{new_ticket.id}.json")

        # shared examples
        expect_response_with_successful

        # custom examples
        expect(response_body).to be_a(Hash)
        expect(response_body.empty?).to eq true
    end

    it "is expected to response with error when a ticket doesn't exist" do

        delete("/help/tickets/0.json")

        # shared examples
        expect_response_with_not_found

        # custom examples
        expect(response_body).to be_a(Hash)
        expect(response_body).to have_key("message")
    end
end