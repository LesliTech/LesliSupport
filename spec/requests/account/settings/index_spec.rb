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

RSpec.describe 'GET:/help/settings.json', type: :request do
    include_context "request user authentication"

    let!(:new_setting) do

        setting_params =  {
            key: Faker::Lorem.word,
            value: Faker::Lorem.word,
        }    

        setting = @current_user.account.help.settings.create!(setting_params)
        setting.save!
        setting
    end

    it 'is expected to respond with all the settings' do
        get '/help/settings.json'
        
        # shared examples
        expect_response_with_successful

        # shared specs
        expect(@response_body_data).to be_a(Object)
        expect(response_body["settings"].last).to be_a(Object)

        expect(response_body["settings"].last).to have_key("id")
        expect(response_body["settings"].last["id"]).to be_a(Integer)

        expect(response_body["settings"].last).to have_key("key")
        expect(response_body["settings"].last["key"]).to be_a(String)
        expect(response_body["settings"].last["key"]).to be_eql(new_setting.key)

        expect(response_body["settings"].last).to have_key("value")
        expect(response_body["settings"].last["value"]).to be_a(String)
        expect(response_body["settings"].last["value"]).to be_eql(new_setting.value)

    end
end