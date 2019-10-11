module CloudHelp
    class ApplicationController < ApplicationCloudController
        protect_from_forgery with: :exception
        before_action :check_account
        
        def check_account

            if current_user.account.help.blank?

                # insert reference to the core account
                current_user.account.help = CloudHelp::Account.new
                current_user.account.help.account = current_user.account
                current_user.account.help.save!

            end

        end

    end
end
