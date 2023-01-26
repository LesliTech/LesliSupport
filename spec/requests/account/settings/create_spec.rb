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
    # test cases

    it "should be able to create a new setting for account" do
        new_setting_params = {
            key: Faker::Lorem.word,
            value: Faker::Lorem.word
        }

        post("/help/settings.json", params: {
            settings: new_setting_params
        })

        expect_response_with_successful
        expect(@current_user.account.help.settings.find_by(key: new_setting_params[:key])[:value]).to be_a(String)
        expect(@current_user.account.help.settings.find_by(key: new_setting_params[:key])[:value]).to eql(new_setting_params[:value])

    end

    it "should respond with error if params are empty" do
        new_setting_params = {}        

        post("/help/settings.json", params: {
            settings: new_setting_params
        })

        expect_response_with_error
    end

    it "should respond with error if params are not sent" do      

        post("/help/settings.json", params: {})

        expect_response_with_error
    end

end
