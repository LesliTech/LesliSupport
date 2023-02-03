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


RSpec.describe "PUT:/help/slas/:id.json", type: :request do
    include_context "request user authentication"
    # test cases

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
            user_main_id: @current_user.id
        }

        sla = CloudHelp::Sla.new(sla_params)
        sla.account = @current_user.account.help
        sla.user_creator = @current_user
        sla.set_workflow
        sla.save!
        sla
    end

    it "is expected to update the sla" do
        new_sla_params = {
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

        put("/help/slas/#{new_sla.id}.json", params: {
            sla: new_sla_params
        })

        expect_response_with_successful

        # shared_expects validates the response body with the given arguments
        shared_expects(response_body, new_sla_params, [
            { key: "id", expected_type: "integer" },
            { key: "name", expected_type: "string", expected_value: new_sla_params[:name] },
            { key: "expected_response_time", expected_type: "integer", expected_value: new_sla_params[:expected_response_time] },
            { key: "expected_resolution_time", expected_type: "integer", expected_value: new_sla_params[:expected_resolution_time] },
            { key: "price_per_hour", expected_type: "decimal", expected_value: new_sla_params[:price_per_hour] },
            { key: "body", price_per_hour: "string", expected_value: new_sla_params[:body] },
            { key: "provider_repercussions", price_per_hour: "string", expected_value: new_sla_params[:provider_repercussions] },
            { key: "client_repercussions", price_per_hour: "string", expected_value: new_sla_params[:client_repercussions] },
            { key: "exceptions", price_per_hour: "string", expected_value: new_sla_params[:exceptions] },
            { key: "default", price_per_hour: "boolean", expected_value: new_sla_params[:default] },
        ])
    end

    it "is expected to respond with not error if params are empty" do
        new_sla_params = {}

        put("/help/slas/#{new_sla.id}.json", params: {
            sla: new_sla_params
        })

        expect_response_with_error

    end

  

end
