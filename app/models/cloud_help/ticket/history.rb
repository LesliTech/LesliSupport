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
module CloudHelp
    class Ticket::History < ApplicationRecord
        belongs_to :ticket, foreign_key: "cloud_help_tickets_id"
        belongs_to :user_creator, class_name: "::User", foreign_key: "users_id"

        def self.index(current_user, query, ticket)
            return unless ticket

            histories = ticket.histories
            .joins(:user_creator)
            .joins("inner join user_details ud on ud.users_id = users.id")
            .select(
                :id,
                :users_id,
                :created_at,
                :content,
                :email,
                "concat(ud.first_name, ' ', ud.last_name) as user_creator_name"
            )
            
            current_user_id = current_user.id
            histories.map do |history|
                {
                    id: history.id,
                    users_id: history.users_id,
                    editable: history.users_id == current_user_id,
                    created_at: LC::Date.to_string_datetime(history.created_at),
                    content: history.content,
                    user_creator_email: history.email,
                    user_creator_name: history.user_creator_name
                }
            end
        end

        def show(current_user, query)
            {
                id: self.id,
                users_id: self.users_id,
                created_at: LC::Date.to_string_datetime(self.created_at),
                content: self.content,
                editable: user_creator == current_user,
                user_creator_email: user_creator.email,
                user_creator_name: user_creator.full_name
            }
        end
    end
end
