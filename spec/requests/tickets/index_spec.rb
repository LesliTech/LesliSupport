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

RSpec.describe "GET:/help/tickets.json", type: :request, if: defined?(CloudHelp) do

    let(:create_ticket) { FactoryBot.create(:cloud_help_ticket )}

    include_context "request user authentication"

    it "is expected to get tickets" do
        new_ticket = create_ticket

        get "/help/tickets.json"
        
        # shared examples
        expect_response_with_pagination

        # specific tests for the response
        expect(response_json).to be_a_kind_of(Hash)
        expect(response_json["records"]).to be_a_kind_of(Array)
        expect(response_json["records"].last).to have_key("id")
        expect(response_json["records"].last["id"]).to be > 0
        expect(response_json["records"].last["id"]).to_not be(nil)
        expect(response_json["records"].last["id"]).to be_a_kind_of(Integer)
        expect(response_json["records"].last).to have_key('subject')
        expect(response_json["records"].last['subject']).to_not be(nil)
        expect(response_json["records"].last['subject']).to be_a_kind_of(String)
        expect(response_json["records"].last).to have_key('deadline')
        expect(response_json["records"].last['deadline']).to_not be(nil)
        expect(response_json["records"].last['deadline']).to be_a_kind_of(String)
        
    end
end