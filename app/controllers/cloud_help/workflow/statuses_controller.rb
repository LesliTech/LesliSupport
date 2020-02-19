require_dependency "cloud_help/application_controller"

module CloudHelp
  class Workflow::StatusesController < ApplicationController
    before_action :set_workflow_status, only: [:show, :edit, :update, :destroy]

    # GET /workflow/statuses
    def index
      @workflow_statuses = Workflow::Status.all
    end

    # GET /workflow/statuses/1
    def show
    end

    # GET /workflow/statuses/new
    def new
      @workflow_status = Workflow::Status.new
    end

    # GET /workflow/statuses/1/edit
    def edit
    end

    # POST /workflow/statuses
    def create
      @workflow_status = Workflow::Status.new(workflow_status_params)

      if @workflow_status.save
        redirect_to @workflow_status, notice: 'Status was successfully created.'
      else
        render :new
      end
    end

    # PATCH/PUT /workflow/statuses/1
    def update
      if @workflow_status.update(workflow_status_params)
        redirect_to @workflow_status, notice: 'Status was successfully updated.'
      else
        render :edit
      end
    end

    # DELETE /workflow/statuses/1
    def destroy
      @workflow_status.destroy
      redirect_to workflow_statuses_url, notice: 'Status was successfully destroyed.'
    end

    private
      # Use callbacks to share common setup or constraints between actions.
      def set_workflow_status
        @workflow_status = Workflow::Status.find(params[:id])
      end

      # Only allow a trusted parameter "white list" through.
      def workflow_status_params
        params.fetch(:workflow_status, {})
      end
  end
end
