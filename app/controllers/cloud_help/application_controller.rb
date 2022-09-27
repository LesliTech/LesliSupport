module CloudHelp
=begin

Copyright (c) 2020, all rights reserved.

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
    class ApplicationController < ApplicationLesliController
        # include Interfaces::Application::Responder
        # include Interfaces::Application::Requester
        protect_from_forgery with: :exception
        before_action :check_account
=begin
@return [void]
@description Checks if the *CloudHelp::Account* record associated to the user's
    *Account* already exists, if not, it is created. This method is not ment to be 
    executed directly. Rather, rails will execute it before any controller action.
@example
    puts current_user.account.help # Asume it displays nil
    # Asume frontend user accesses a controller method through HTTP
    puts current_user.account.help # Will display an instance of CloudHelp::Account
=end
        def check_account
            if current_user.account.help.blank?
                account = CloudHelp::Account.new(account: current_user.account)
                current_user.account.help = account
                account.save!
            end
        end
    end
end
