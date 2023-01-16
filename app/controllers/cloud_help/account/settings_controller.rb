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
    class Account::SettingsController < ApplicationLesliController
        before_action :set_account_setting, only: [:destroy]

        def privileges
            {
                new: [],
                index: ["options"],
                destroy: []
            }
        end

        # GET /settings
        def index
            respond_to do |format|
                format.html {}
                format.json {
                    respond_with_successful(Account::Setting.index(current_user, @query))
                }
            end
        end

        # POST /settings
        def create
            if account_settings_params.empty?
                return respond_with_not_found
            end

            account_settings_params.each do |param|
                setting = current_user.account.help.settings.find_by(key: account_settings_params[:key])
                if setting.present?
                    setting.update(value: account_settings_params[:value])
                else
                    current_user.account.help.settings.create!(key:account_settings_params[:key], value: account_settings_params[:value])
                end
            end

            respond_with_successful
        end

        # DELETE /settings/1
        def destroy
            return respond_with_not_found unless @setting
            return respond_with_unauthorized unless @setting.protected
            
            if @setting.destroy
                respond_with_successful
            else
                respond_with_error(@setting.error.full_messages.to_sentence)
            end
        end

        # GET /settings/options
        def options
            respond_with_successful(Account::Setting.options(current_user, @query))
        end

        private

        # @return [void]
        # @description Sets the setting based on the current_users's account
        # @example
        #     # Executing this method from a controller action:
        #     set_account_setting
        #     puts @setting
        #     # This will either display nil or an instance of Account::Setting
        def set_account_setting
            @setting = current_user.account.help.settings.find_by(id: params[:id])
        end


        def account_settings_params
            params.require(:settings).permit(:key, :value)
        end

    end
end
