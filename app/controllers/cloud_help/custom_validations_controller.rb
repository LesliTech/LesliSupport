require_dependency "cloud_help/application_controller"

module CloudHelp
  class CustomValidationsController < ApplicationController
    before_action :set_custom_validation, only: [:show, :edit, :update, :destroy]

    # GET /custom_validations
    def index
      @custom_validations = CustomValidation.all
    end

    # GET /custom_validations/1
    def show
    end

    # GET /custom_validations/new
    def new
      @custom_validation = CustomValidation.new
    end

    # GET /custom_validations/1/edit
    def edit
    end

    # POST /custom_validations
    def create
      @custom_validation = CustomValidation.new(custom_validation_params)

      if @custom_validation.save
        redirect_to @custom_validation, notice: 'Custom validation was successfully created.'
      else
        render :new
      end
    end

    # PATCH/PUT /custom_validations/1
    def update
      if @custom_validation.update(custom_validation_params)
        redirect_to @custom_validation, notice: 'Custom validation was successfully updated.'
      else
        render :edit
      end
    end

    # DELETE /custom_validations/1
    def destroy
      @custom_validation.destroy
      redirect_to custom_validations_url, notice: 'Custom validation was successfully destroyed.'
    end

    private
      # Use callbacks to share common setup or constraints between actions.
      def set_custom_validation
        @custom_validation = CustomValidation.find(params[:id])
      end

      # Only allow a trusted parameter "white list" through.
      def custom_validation_params
        params.fetch(:custom_validation, {})
      end
  end
end
