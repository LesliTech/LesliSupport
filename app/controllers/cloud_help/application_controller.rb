module CloudHelp
    class ApplicationController < ApplicationLesliController
        protect_from_forgery with: :exception
        before_action :check_account
        
        def check_account

            if current_user.account.help.blank?

                # insert reference to the core account
                account = CloudHelp::Account.new(account: current_user.account)
                current_user.account.help = account
                account.save!

            end

        end

    end
end
