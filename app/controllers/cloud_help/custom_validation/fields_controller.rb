require_dependency "cloud_help/application_controller"

module CloudHelp
  class CustomValidation::FieldsController < ApplicationController
    before_action :set_custom_validation_field, only: [:show, :edit, :update, :destroy]

    # GET /custom_validation/fields
    def index
      @custom_validation_fields = CustomValidation::Field.all
    end

    # GET /custom_validation/fields/1
    def show
    end

    # GET /custom_validation/fields/new
    def new
      @custom_validation_field = CustomValidation::Field.new
    end

    # GET /custom_validation/fields/1/edit
    def edit
    end

    # POST /custom_validation/fields
    def create
      @custom_validation_field = CustomValidation::Field.new(custom_validation_field_params)

      if @custom_validation_field.save
        redirect_to @custom_validation_field, notice: 'Field was successfully created.'
      else
        render :new
      end
    end

    # PATCH/PUT /custom_validation/fields/1
    def update
      if @custom_validation_field.update(custom_validation_field_params)
        redirect_to @custom_validation_field, notice: 'Field was successfully updated.'
      else
        render :edit
      end
    end

    # DELETE /custom_validation/fields/1
    def destroy
      @custom_validation_field.destroy
      redirect_to custom_validation_fields_url, notice: 'Field was successfully destroyed.'
    end

    private
      # Use callbacks to share common setup or constraints between actions.
      def set_custom_validation_field
        @custom_validation_field = CustomValidation::Field.find(params[:id])
      end

      # Only allow a trusted parameter "white list" through.
      def custom_validation_field_params
        params.fetch(:custom_validation_field, {})
      end
  end
end
