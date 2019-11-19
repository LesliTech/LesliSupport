require_dependency "cloud_help/application_controller"

module CloudHelp
    class State::AssignmentsController < ApplicationController
        before_action :set_states_action, only: [:show, :edit, :update, :destroy]

        # GET /state/assignments
        def index
            respond_to do |format|
                format.html {}
                format.json do 
                    ticket_categories = State::Assignment.where()
                    responseWithSuccessful(ticket_categories)
                end
            end
        end

        # GET /states/assignments/1
        def show
        end

        # GET /states/assignments/new
        def new
            @states_action = states::Action.new
        end

        # GET /states/assignments/1/edit
        def edit
        end

        # POST /states/assignments
        def create
            states_action = states::Action.new(states_action_params)
            if states_action.save
                responseWithSuccessful(states_action)
            else
                responseWithError("Action not created")
            end
        end

        # PATCH/PUT /states/assignments/1
        def update
            if @states_action.update(states_action_params)
                responseWithSuccessful(@states_action)
            else
                responseWithError("Action not updated")
            end
        end

        # DELETE /states/assignments/1
        def destroy
            @states_action.destroy
            redirect_to states_assignments_url, notice: 'Action was successfully destroyed.'
        end

        private

        # Use callbacks to share common setup or constraints between assignments.
        def set_states_action
            @states_action = states::Action.find(params[:id])
        end

        # Only allow a trusted parameter "white list" through.
        def states_action_params
            params.require(:states_action).permit(:id, :type, :instructions, :deadline, :complete, :tags, :cloud_help_statess_id)
        end

    end
end
