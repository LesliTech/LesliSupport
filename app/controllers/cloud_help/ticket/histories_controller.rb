=begin
Copyright (c) 2022, all rights reserved.

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
require_dependency "cloud_help/application_controller"

module CloudHelp
    class Ticket::HistoriesController < ApplicationController
        before_action :set_ticket, only: [:index, :create]
        before_action :set_ticket_history, only: [:show, :update, :destroy]

        # GET /ticket/histories.json
        def index
            return respond_with_not_found unless @ticket

            respond_with_successful(Ticket::History.index(current_user, @query, @ticket))
        end

        # GET /ticket/histories/1.json
        def show
            return respond_with_not_found unless @ticket_history
            return respond_with_successful(@ticket_history.show(current_user, @query))
        end

        # POST /ticket/histories
        def create
            return respond_with_not_found unless @ticket
            ticket_history = @ticket.histories.new(ticket_history_params)

            if ticket_history.save
                respond_with_successful(ticket_history)
            else
                respond_with_error(ticket_history.errors.full_messages.to_sentence)
            end
        end

        # PATCH/PUT /ticket/histories/1
        def update
            return respond_with_not_found unless @ticket_history

            if @ticket_history.update(ticket_history_params)
                respond_with_successful(@ticket_history.show(current_user, @query))
            else
                respond_with_error(@ticket_history.errors.full_messages.to_sentence)
            end
        end

        # DELETE /ticket/histories/1
        def destroy
            return respond_with_not_found unless @ticket_history

            if @ticket_history.destroy
                respond_with_successful
            else
                respond_with_error(@ticket_history.errors.full_messages.to_sentence)
            end
        end

        private

        # @return [void]
        # @description Sets the variable @ticket. The variable contains the *ticket*
        #     to be handled by the controller action that called this method
        # @example
        #     #suppose params[:ticket_id] = 1
        #     puts @ticket # will display nil
        #     set_ticket
        #     puts @ticket # will display an instance of CloudHelp:Ticket
        def set_ticket
            @ticket = current_user.account.help.tickets.find_by_id(params[:ticket_id) if  params[:ticket_id]
        end

        # @return [void]
        # @description Sets the variable @ticket_history. The variable contains the *ticket_history*
        #     to be handled by the controller action that called this method. If the variable @ticket
        #     cannot be set, then @ticket_history is not set
        # @example
        #     #suppose params[:ticket_id] = 1
        #     #suppose params[:id] = 1
        #     puts @ticket_history # will display nil
        #     set_ticket_history
        #     puts @set_ticket_history # will display an instance of CloudHelp:Ticket::History
        def set_ticket_history
            set_ticket
            return unless @ticket
                
            @ticket_history = current_user.account.ticket_histories.find(class_name, params[:id]) if params[:id]
        end

        # @return [Parameters] Allowed parameters for the ticket history
        # @description Sanitizes the parameters received from an HTTP call to only allow the specified ones.
        #     Allowed params are :users_id, :content, :label
        # @example
        #     # supose params contains {
        #     #    "ticket_assignment": {
        #     #        "id": 5,
        #     #        "users_id": 6,
        #     #        "content": "This is the content"
        #     #    }
        #     #}
        #     filtered_params = ticket_history_params
        #     puts filtered_params
        #     # will remove all extra fields and only print {
        #     #    "users_id": 6,
        #     #    "content": "This is the content"
        #     #}
        def ticket_history_params
            params.fetch(:ticket_history, {}).permit(:users_id, :content, :label)
        end
    end
end
