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

RSpec.describe 'GET:/help/slas.json', type: :request do
    include_context "request user authentication"

    let!(:new_sla) do

        sla_params = {
            name: Faker::Lorem.word,
            expected_response_time: Faker::Number.number(digits: 4),
            expected_resolution_time: Faker::Number.number(digits: 4),
            price_per_hour:  Faker::Number.decimal(l_digits: 2, r_digits: 1),
            body: Faker::Lorem.paragraph,
            provider_repercussions: Faker::Lorem.paragraph,
            client_repercussions: Faker::Lorem.paragraph,
            exceptions: Faker::Lorem.paragraph,
            default: Faker::Boolean.boolean(true_ratio: 0.5),
        }
        

        sla = CloudHelp::Sla.new(sla_params)
        sla.account = @current_user.account.help
        sla.user_creator = @current_user
        sla.set_workflow
        sla.save!
        sla
    end

    it 'is expected to respond with all the workflows' do
        get '/help/slas.json'
        
        # shared examples
        expect_response_with_successful

        # shared specs
        expect(@response_body_data).to be_a(Object)
        expect(response_body["records"][0]).to be_a(Object)

        expect(response_body["records"][0]).to have_key("id")
        expect(response_body["records"][0]["id"]).to be_a(Integer)

        expect(response_body["records"][0]).to have_key("name")
        expect(response_body["records"][0]["name"]).to be_a(String)
        expect(response_body["records"][0]["name"]).to be_eql(new_sla.name)

        expect(response_body["records"][0]).to have_key("default")
        expect(response_body["records"][0]["default"]).to be_in([true, false])
        expect(response_body["records"][0]["default"]).to be_eql(new_sla.default)

        expect(response_body["records"][0]).to have_key("created_at")
        expect(response_body["records"][0]["created_at"]).to be_a(String)

        expect(response_body["records"][0]).to have_key("body")
        expect(response_body["records"][0]["body"]).to be_a(String)
        expect(response_body["records"][0]["body"]).to be_eql(new_sla.body)

        expect(response_body["records"][0]).to have_key("expected_response_time")
        expect(response_body["records"][0]["expected_response_time"]).to be_a(Integer)
        expect(response_body["records"][0]["expected_response_time"]).to be_eql(new_sla.expected_response_time)
        
        expect(response_body["records"][0]).to have_key("expected_resolution_time")
        expect(response_body["records"][0]["expected_resolution_time"]).to be_a(Integer)
        expect(response_body["records"][0]["expected_resolution_time"]).to be_eql(new_sla.expected_resolution_time)

        expect(response_body["records"][0]).to have_key("provider_repercussions")
        expect(response_body["records"][0]["provider_repercussions"]).to be_a(String)
        expect(response_body["records"][0]["provider_repercussions"]).to be_eql(new_sla.provider_repercussions)

        expect(response_body["records"][0]).to have_key("exceptions")
        expect(response_body["records"][0]["exceptions"]).to be_a(String)
        expect(response_body["records"][0]["exceptions"]).to be_eql(new_sla.exceptions)


        expect(response_body["records"][0]).to have_key("cloud_help_workflow_statuses_id")
        expect(response_body["records"][0]["cloud_help_workflow_statuses_id"]).to be_a(Integer)

        expect(response_body["records"][0]).to have_key("status")
        expect(response_body["records"][0]["status"]).to be_a(String)

        expect(response_body["records"][0]).to have_key("users_id")
        expect(response_body["records"][0]["users_id"]).to be_a(Integer)

        expect(response_body["records"][0]).to have_key("editable")
        expect(response_body["records"][0]["editable"]).to be_in([true, false])

        expect(response_body["records"][0]).to have_key("user_main_id")

    end
end
