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

FactoryBot.define do
    factory :cloud_help_ticket, class: "CloudHelp::Ticket" do
        subject { Faker::Lorem.word }
        description { Faker::Lorem.sentence }
        deadline { Faker::Time.forward(days: 1) }
        tags { "#{Faker::Lorem.word}, #{Faker::Lorem.word}, #{Faker::Lorem.word}, #{Faker::Lorem.word}" }
        reference_url { Faker::Internet.url }
        hours_worked { rand(1...12) }

        account { CloudHelp::Account.first }
        user_creator { ::User.first }
    end 
end