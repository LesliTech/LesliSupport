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


RSpec.describe "PUT:/help/tickets/:id", type: :request do

    let(:create_ticket) { FactoryBot.create(:cloud_help_ticket )}
    
    include_context "request user authentication"

    it "is expected to update a ticket" do

        new_ticket = create_ticket

        # update params
        ticket_params = {
            subject: Faker::Lorem.sentence(word_count: 3),
            description: Faker::Lorem.sentence(word_count: 6),
            deadline: Time.now,
            tags: "#{Faker::Lorem.word}, #{Faker::Lorem.word}, #{Faker::Lorem.word}, #{Faker::Lorem.word}",
            reference_url: Faker::Internet.url,
            hours_worked: rand(1.0...12.0).round(1).to_s
        }
        
        put("/help/tickets/#{new_ticket.id}.json", params: { ticket: ticket_params}  )

        # shared examples
        expect_response_with_successful

        # custom examples
        expect(response_json).to have_key("subject")
        expect(response_json["subject"]).to eql(ticket_params[:subject])
        expect(response_json).to have_key("description")
        expect(response_json["description"]).to eql(ticket_params[:description])
        expect(response_json).to have_key("deadline")
        expect(LC::Date2.new(Time.parse(response_json["deadline"])).date_time.to_s).to eql(LC::Date2.new(ticket_params[:deadline]).date_time.to_s)
        expect(response_json).to have_key("tags")
        expect(response_json["tags"]).to eql(ticket_params[:tags])
        expect(response_json).to have_key("reference_url")
        expect(response_json["reference_url"]).to eql(ticket_params[:reference_url])
        expect(response_json).to have_key("hours_worked")
        expect(response_json["hours_worked"]).to eql(ticket_params[:hours_worked])
    end

    it "is expected to response with error when no params sent" do
        
        new_ticket = create_ticket

        put("/help/tickets/#{new_ticket.id}.json", params: {}  )

        # shared examples
        expect_response_with_error

    end

end