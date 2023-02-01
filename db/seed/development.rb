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

ticket = CloudHelp::Ticket.new({
    subject: Faker::Lorem.word,
    description: Faker::Lorem.paragraph,
    deadline: Time.now,
    tags: "#{Faker::Lorem.word},#{Faker::Lorem.word},#{Faker::Lorem.word},#{Faker::Lorem.word}",
    reference_url: Faker::Internet.url
})

ticket.source = Catalog::TicketSource.cloud_help_source(::User.first.account.help)
ticket.user_creator = ::User.first



