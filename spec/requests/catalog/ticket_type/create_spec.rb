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

RSpec.describe 'POST:/help/catalog/ticket_types', type: :request do
    include_context "request user authentication"

    it "is expected to create a new ticket type" do

        type_params = {
            name: Faker::Lorem.word
        }

        post("/help/catalog/ticket_types.json", params: {
            ticket_type: type_params
        })

        # shared examples
        expect_response_with_successful

        # custom specs
        expect(response_body).to be_a(Object)

        expect(response_body).to have_key("id")
        expect(response_body["id"]).to be_a(Integer)

        expect(response_body).to have_key("name")
        expect(response_body["name"]).to be_a(String)
        expect(response_body["name"]).to eql(type_params[:name])

        expect(response_body).to have_key("cloud_help_accounts_id")
        expect(response_body["cloud_help_accounts_id"]).to be_a(Integer)

    end

    it "is expected to respond with error if type params are not sent " do

        post("/help/catalog/ticket_types.json")

        # shared examples
        expect_response_with_error
    end

    it "is expected to respond with error if type params are empty" do

        type_params = {}

        post("/help/catalog/ticket_types.json", params: {
            ticket_type: type_params
        })

        # shared examples
        expect_response_with_error
    end

end
