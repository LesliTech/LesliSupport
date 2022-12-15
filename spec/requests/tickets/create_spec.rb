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


RSpec.describe "POST:/help/tickets.json", type: :request do
    include_context "request user authentication"
    # test cases

    it "should be able to create a ticket only with subject" do
        new_ticket_params = {
            subject: Faker::Lorem.word
        }

        post("/help/tickets.json", params: {
            ticket: new_ticket_params
        })

        expect_response_with_successful

        # shared_expects validates the response body with the given arguments
        shared_expects(response_body, new_ticket_params, [
            { key: "id", expected_type: "integer" },
            { key: "subject", expected_type: "string", expected_value: new_ticket_params[:subject] },
            { key: "description", expected_type: "nil" },
            { key: "tags", expected_type: "nil" },
            { key: "hours_worked", expected_type: "nil" },
            { key: "cloud_help_accounts_id", expected_type: "integer" },
            { key: "users_id", expected_type: "integer" },
            { key: "cloud_help_catalog_ticket_priorities_id", expected_type: "nil" },
            { key: "cloud_help_catalog_ticket_categories_id", expected_type: "nil" },
            { key: "cloud_help_catalog_ticket_types_id", expected_type: "nil" },
            { key: "cloud_help_catalog_ticket_sources_id", expected_type: "nil" },
            { key: "reference_url", expected_type: "nil" },
            { key: "deadline", expected_type: "string" }
        ])
    end

    it "should be able to create a ticket with all the params from ticket form" do
        new_ticket_params = {
            subject: Faker::Lorem.word,
            description: Faker::Lorem.paragraph,
            deadline: Time.now,
            tags: "#{Faker::Lorem.word},#{Faker::Lorem.word},#{Faker::Lorem.word},#{Faker::Lorem.word}",
            reference_url: Faker::Internet.url
        }

        post("/help/tickets.json", params: {
            ticket: new_ticket_params
        })

        expect_response_with_successful

        # shared_expects validates the response body with the given arguments
        shared_expects(response_body, new_ticket_params, [
            { key: "id", expected_type: "integer" },
            { key: "subject", expected_type: "string", expected_value: new_ticket_params[:subject] },
            { key: "description", expected_type: "string", expected_value: new_ticket_params[:description] },
            { key: "tags", expected_type: "string", expected_value: new_ticket_params[:tags] },
            { key: "hours_worked", expected_type: "nil" },
            { key: "cloud_help_accounts_id", expected_type: "integer" },
            { key: "users_id", expected_type: "integer" },
            { key: "cloud_help_catalog_ticket_priorities_id", expected_type: "nil" },
            { key: "cloud_help_catalog_ticket_categories_id", expected_type: "nil" },
            { key: "reference_url", expected_type: "string", expected_value: new_ticket_params[:reference_url] },
            { key: "deadline", expected_type: "string" }
        ])
    end

end
