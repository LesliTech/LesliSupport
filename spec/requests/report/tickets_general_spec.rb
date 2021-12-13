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
require "lesli_request_helper"
require "./engines/cloud_help/spec/requests/ticket/helper"

RSpec.configure do |config|
    config.include Requests::Ticket::Helper
end

RSpec.describe "GET:/help/repots/tickets_general.xlsx with no filters", type: :request do
    include_context "user authentication"

    it "is expected to respond with a xlsx file" do
        
        # Setup
        20.times do 
            build_random_ticket(@user)
        end

        # Request
        get "/help/reports/tickets_general.xlsx" 

        # Checks
        expect(response).to have_http_status(:success)
        expect(response.content_type).to eq("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet")
    end
end

RSpec.describe "GET:/help/repots/tickets_general.xlsx with filters", type: :request do
    include_context "user authentication"

    it "is expected to respond with a xlsx file" do
        
        # Setup
        20.times do 
            build_random_ticket(@user)
        end

        user_assigned_id = User.order("random()").first.id
        start_date = LC::Date.datetime(Faker::Time.between(from: DateTime.now - 3.days, to: DateTime.now)).iso8601
        end_date = LC::Date.datetime(Faker::Time.between(from: DateTime.now, to: DateTime.now + 3.days)).iso8601

        # Request
        get "/help/reports/tickets_general.xlsx?filters[user_assigned_id]=#{user_assigned_id}&start_date=#{start_date}&end_date=#{end_date}" 

        # Checks
        expect(response).to have_http_status(:success)
        expect(response.content_type).to eq("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet")
    end
end
