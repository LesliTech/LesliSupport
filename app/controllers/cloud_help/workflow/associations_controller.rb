require_dependency "cloud_help/application_controller"

module CloudHelp
  class Workflow::AssociationsController < ApplicationController
    before_action :set_workflow_association, only: [:show, :edit, :update, :destroy]

    # GET /workflow/associations
    def index
      @workflow_associations = Workflow::Association.all
    end

    # GET /workflow/associations/1
    def show
    end

    # GET /workflow/associations/new
    def new
      @workflow_association = Workflow::Association.new
    end

    # GET /workflow/associations/1/edit
    def edit
    end

    # POST /workflow/associations
    def create
      @workflow_association = Workflow::Association.new(workflow_association_params)

      if @workflow_association.save
        redirect_to @workflow_association, notice: 'Association was successfully created.'
      else
        render :new
      end
    end

    # PATCH/PUT /workflow/associations/1
    def update
      if @workflow_association.update(workflow_association_params)
        redirect_to @workflow_association, notice: 'Association was successfully updated.'
      else
        render :edit
      end
    end

    # DELETE /workflow/associations/1
    def destroy
      @workflow_association.destroy
      redirect_to workflow_associations_url, notice: 'Association was successfully destroyed.'
    end

    private
      # Use callbacks to share common setup or constraints between actions.
      def set_workflow_association
        @workflow_association = Workflow::Association.find(params[:id])
      end

      # Only allow a trusted parameter "white list" through.
      def workflow_association_params
        params.fetch(:workflow_association, {})
      end
  end
end
