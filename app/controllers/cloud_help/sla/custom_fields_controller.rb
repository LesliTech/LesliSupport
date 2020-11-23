require_dependency "cloud_help/application_controller"

module CloudHelp
  class Sla::CustomFieldsController < ApplicationController
    before_action :set_sla_custom_field, only: [:show, :edit, :update, :destroy]

    # GET /sla/custom_fields
    def index
      @sla_custom_fields = Sla::CustomField.all
    end

    # GET /sla/custom_fields/1
    def show
    end

    # GET /sla/custom_fields/new
    def new
      @sla_custom_field = Sla::CustomField.new
    end

    # GET /sla/custom_fields/1/edit
    def edit
    end

    # POST /sla/custom_fields
    def create
      @sla_custom_field = Sla::CustomField.new(sla_custom_field_params)

      if @sla_custom_field.save
        redirect_to @sla_custom_field, notice: 'Custom field was successfully created.'
      else
        render :new
      end
    end

    # PATCH/PUT /sla/custom_fields/1
    def update
      if @sla_custom_field.update(sla_custom_field_params)
        redirect_to @sla_custom_field, notice: 'Custom field was successfully updated.'
      else
        render :edit
      end
    end

    # DELETE /sla/custom_fields/1
    def destroy
      @sla_custom_field.destroy
      redirect_to sla_custom_fields_url, notice: 'Custom field was successfully destroyed.'
    end

    private
      # Use callbacks to share common setup or constraints between actions.
      def set_sla_custom_field
        @sla_custom_field = Sla::CustomField.find(params[:id])
      end

      # Only allow a trusted parameter "white list" through.
      def sla_custom_field_params
        params.fetch(:sla_custom_field, {})
      end
  end
end
