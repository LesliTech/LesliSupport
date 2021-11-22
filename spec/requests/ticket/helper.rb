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
module Requests
    module Ticket
        module Helper
            def build_random_ticket(user)
                account = user.account
                help_account = account.help

                ticket = help_account.tickets.new({
                    subject: Faker::Lorem.word,
                    user_creator: user,
                    category: help_account.ticket_categories.order("random()").first,
                    priority: help_account.ticket_priorities.order("random()").first,
                    source: help_account.ticket_sources.order("random()").first,
                    type: help_account.ticket_types.order("random()").first,
                    sla: help_account.slas.order("random()").first
                })

                ticket.set_workflow
                ticket.save!

                return ticket
            end

            def build_random_ticket_action(user, ticket, group: nil)
                group = Faker::Lorem.word unless group

                ticket.actions.create!({
                    user_creator: user,
                    instructions: Faker::Lorem.sentence(word_count: 5),
                    complete: false,
                    group: group
                })
            end

            def build_ticket_action_params(user, group: nil)
                group = Faker::Lorem.word unless group

                {
                    ticket_action: {
                        instructions: Faker::Lorem.sentence(word_count: 5),
                        complete: Faker::Boolean.boolean,
                        group: group
                    }
                }
            end

            def ticket_params(user)
                help_account = user.account.help

                {
                    ticket: {
                        subject: Faker::Lorem.word,
                        description: Faker::Lorem.sentence,
                        tags: Faker::Lorem.words(number: 4).join(","),
                        hours_worked: Faker::Number.between(from: 1, to: 20),
                        cloud_help_catalog_ticket_categories_id: help_account.ticket_categories.order("random()").first.id,
                        cloud_help_catalog_ticket_priorities_id: help_account.ticket_priorities.order("random()").first.id,
                        cloud_help_catalog_ticket_sources_id: help_account.ticket_sources.order("random()").first.id,
                        cloud_help_catalog_ticket_types_id: help_account.ticket_types.order("random()").first.id,
                        cloud_help_slas_id: help_account.slas.order("random()").first.id,
                        deadline: Faker::Date.between(from: Date.today, to: 5.days.from_now),
                    }
                }
            end
        end
    end
end
