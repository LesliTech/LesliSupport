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

require "lesli_request_helper"


RSpec.describe "POST:/help/settings.json", type: :request do
    include_context "request user authentication"
    it "is expected to respond with key values and format" do
        get("/help/settings/options.json")

        #share examples
        expect_response_with_successful

        #keyvalues
        expect(@response_body_data).to be_a(Object)
        expect(response_body["roles"][0]).to be_a(Object)

        expect(response_body["roles"][0]).to have_key("value")
        expect(response_body["roles"][0]["value"]).to be_a(Integer)

        expect(response_body["roles"][0]).to have_key("label")
        expect(response_body["roles"][0]["label"]).to be_a(String)
    end 
end




