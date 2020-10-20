require_dependency "cloud_help/application_controller"

module CloudHelp
  class Workflow::ActionsController < ApplicationController
    before_action :set_workflow_action, only: [:show, :edit, :update, :destroy]

    # GET /workflow/actions
    def index
      @workflow_actions = Workflow::Action.all
    end

    # GET /workflow/actions/1
    def show
    end

    # GET /workflow/actions/new
    def new
      @workflow_action = Workflow::Action.new
    end

    # GET /workflow/actions/1/edit
    def edit
    end

    # POST /workflow/actions
    def create
      @workflow_action = Workflow::Action.new(workflow_action_params)

      if @workflow_action.save
        redirect_to @workflow_action, notice: 'Action was successfully created.'
      else
        render :new
      end
    end

    # PATCH/PUT /workflow/actions/1
    def update
      if @workflow_action.update(workflow_action_params)
        redirect_to @workflow_action, notice: 'Action was successfully updated.'
      else
        render :edit
      end
    end

    # DELETE /workflow/actions/1
    def destroy
      @workflow_action.destroy
      redirect_to workflow_actions_url, notice: 'Action was successfully destroyed.'
    end

    private
      # Use callbacks to share common setup or constraints between actions.
      def set_workflow_action
        @workflow_action = Workflow::Action.find(params[:id])
      end

      # Only allow a trusted parameter "white list" through.
      def workflow_action_params
        params.fetch(:workflow_action, {})
      end
  end
end
