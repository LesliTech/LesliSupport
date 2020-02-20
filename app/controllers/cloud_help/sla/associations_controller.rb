require_dependency "cloud_help/application_controller"

module CloudHelp
  class Sla::AssociationsController < ApplicationController
    before_action :set_sla_association, only: [:show, :edit, :update, :destroy]

    # GET /sla/associations
    def index
      @sla_associations = Sla::Association.all
    end

    # GET /sla/associations/1
    def show
    end

    # GET /sla/associations/new
    def new
      @sla_association = Sla::Association.new
    end

    # GET /sla/associations/1/edit
    def edit
    end

    # POST /sla/associations
    def create
      @sla_association = Sla::Association.new(sla_association_params)

      if @sla_association.save
        redirect_to @sla_association, notice: 'Association was successfully created.'
      else
        render :new
      end
    end

    # PATCH/PUT /sla/associations/1
    def update
      if @sla_association.update(sla_association_params)
        redirect_to @sla_association, notice: 'Association was successfully updated.'
      else
        render :edit
      end
    end

    # DELETE /sla/associations/1
    def destroy
      @sla_association.destroy
      redirect_to sla_associations_url, notice: 'Association was successfully destroyed.'
    end

    private
      # Use callbacks to share common setup or constraints between actions.
      def set_sla_association
        @sla_association = Sla::Association.find(params[:id])
      end

      # Only allow a trusted parameter "white list" through.
      def sla_association_params
        params.fetch(:sla_association, {})
      end
  end
end
