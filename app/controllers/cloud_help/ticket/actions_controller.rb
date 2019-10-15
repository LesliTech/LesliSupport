require_dependency "cloud_help/application_controller"

module CloudHelp
    class Ticket::ActionsController < ApplicationController
        before_action :set_ticket_action, only: [:show, :edit, :update, :destroy]

        # GET /ticket/actions
        def index
            @ticket_actions = Ticket::Action.all
        end

        # GET /ticket/actions/1
        def show
        end

        # GET /ticket/actions/new
        def new
            @ticket_action = Ticket::Action.new
        end

        # GET /ticket/actions/1/edit
        def edit
        end

        # POST /ticket/actions
        def create
            ticket_action = Ticket::Action.new(ticket_action_params)
            if ticket_action.save
                CloudBell::NotificationsController.web_notification
                responseWithSuccessful(ticket_action)
            else
                responseWithError("Action not created")
            end
        end

        # PATCH/PUT /ticket/actions/1
        def update
            if @ticket_action.update(ticket_action_params)
                redirect_to @ticket_action, notice: 'Action was successfully updated.'
            else
                render :edit
            end
        end

        # DELETE /ticket/actions/1
        def destroy
            @ticket_action.destroy
            redirect_to ticket_actions_url, notice: 'Action was successfully destroyed.'
        end

        private

        # Use callbacks to share common setup or constraints between actions.
        def set_ticket_action
            @ticket_action = Ticket::Action.find(params[:id])
        end

        # Only allow a trusted parameter "white list" through.
        def ticket_action_params
            params.require(:ticket_action).permit(:instructions, :cloud_help_tickets_id)
        end

    end
end
