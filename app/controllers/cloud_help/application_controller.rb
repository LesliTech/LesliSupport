module CloudHelp
=begin

Lesli

Copyright (c) 2020, Lesli Technologies, S. A.

All the information provided by this website is protected by laws of Guatemala related 
to industrial property, intellectual property, copyright and relative international laws. 
Lesli Technologies, S. A. is the exclusive owner of all intellectual or industrial property
rights of the code, texts, trade mark, design, pictures and any other information.
Without the written permission of Lesli Technologies, S. A., any replication, modification,
transmission, publication is strictly forbidden.
For more information read the license file including with this software.

LesliCloud - Your Smart Business Assistant

Powered by https://www.lesli.tech
Building a better future, one line of code at a time.

@author   ldonis & Carlos Hermosilla
@license  Propietary - all rights reserved.
@version  0.1.0-alpha
@description Base controller for the *help* engine

=end
    class ApplicationController < ApplicationLesliController
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
