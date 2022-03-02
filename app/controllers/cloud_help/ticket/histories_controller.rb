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
require_dependency "cloud_help/application_controller"

module CloudHelp
  class Ticket::HistoriesController < ApplicationController
      before_action :set_ticket_history, only: [:show, :update, :destroy]

      # GET /ticket/histories
      def index
          respond_to do |format|
              format.html {}
              format.json do
                  respond_with_successful(Ticket::History.index(current_user, @query))
              end
          end
      end

      # GET /ticket/histories/1
      def show
          respond_to do |format|
              format.html {}
              format.json do
                  return respond_with_not_found unless @ticket_history
                  return respond_with_successful(@ticket_history.show(current_user, @query))
              end
          end
      end

      # GET /ticket/histories/new
      def new
      end

      # GET /ticket/histories/1/edit
      def edit
      end

      # POST /ticket/histories
      def create
          ticket_history = Ticket::History.new(ticket_history_params)
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

      # Use callbacks to share common setup or constraints between actions.
      def set_ticket_history
          @ticket_history = current_user.account.ticket_histories.find(class_name, params[:id])
      end

      # Only allow a list of trusted parameters through.
      def ticket_history_params
          params.require(:ticket_history).permit(:id, :name)
      end
  end
end
