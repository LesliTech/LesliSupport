require_dependency "cloud_help/application_controller"

module CloudHelp
  class Workflow::DetailsController < ApplicationController
    before_action :set_workflow_detail, only: [:show, :edit, :update, :destroy]

    # GET /workflow/details
    def index
      @workflow_details = Workflow::Detail.all
    end

    # GET /workflow/details/1
    def show
    end

    # GET /workflow/details/new
    def new
      @workflow_detail = Workflow::Detail.new
    end

    # GET /workflow/details/1/edit
    def edit
    end

    # POST /workflow/details
    def create
      @workflow_detail = Workflow::Detail.new(workflow_detail_params)

      if @workflow_detail.save
        redirect_to @workflow_detail, notice: 'Detail was successfully created.'
      else
        render :new
      end
    end

    # PATCH/PUT /workflow/details/1
    def update
      if @workflow_detail.update(workflow_detail_params)
        redirect_to @workflow_detail, notice: 'Detail was successfully updated.'
      else
        render :edit
      end
    end

    # DELETE /workflow/details/1
    def destroy
      @workflow_detail.destroy
      redirect_to workflow_details_url, notice: 'Detail was successfully destroyed.'
    end

    private
      # Use callbacks to share common setup or constraints between actions.
      def set_workflow_detail
        @workflow_detail = Workflow::Detail.find(params[:id])
      end

      # Only allow a trusted parameter "white list" through.
      def workflow_detail_params
        params.fetch(:workflow_detail, {})
      end
  end
end
