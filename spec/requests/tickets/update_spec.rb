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


RSpec.describe "PUT:/help/tickets/:id", type: :request, if: defined?(CloudHelp) do

    let(:create_ticket) { FactoryBot.create(:cloud_help_ticket )}
    
    include_context "request user authentication"

    it "is expected to update a ticket" do

        new_ticket = create_ticket
        # update params
        ticket_params = {
            subject: Faker::Lorem.sentence(word_count: 3),
            description: Faker::Lorem.sentence(word_count: 6),
        }

        put("/help/tickets/#{new_ticket.id}.json", params: { ticket: ticket_params}  )

        # shared examples
        expect_response_with_successful

        # custom examples
        expect(response_body).to have_key("subject")
        expect(response_body["subject"]).to eql(ticket_params[:subject])

        expect(response_body).to have_key("description")
        expect(response_body["description"]).to eql(ticket_params[:description])
    end

    it "is expected to response with error when no params sent" do
        
        new_ticket = create_ticket

        put("/help/tickets/#{new_ticket.id}.json", params: {}  )

        # shared examples
        expect_response_with_error

    end

end