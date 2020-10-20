require_dependency "cloud_help/application_controller"

module CloudHelp
  class CustomValidation::RulesController < ApplicationController
    before_action :set_custom_validation_rule, only: [:show, :edit, :update, :destroy]

    # GET /custom_validation/rules
    def index
      @custom_validation_rules = CustomValidation::Rule.all
    end

    # GET /custom_validation/rules/1
    def show
    end

    # GET /custom_validation/rules/new
    def new
      @custom_validation_rule = CustomValidation::Rule.new
    end

    # GET /custom_validation/rules/1/edit
    def edit
    end

    # POST /custom_validation/rules
    def create
      @custom_validation_rule = CustomValidation::Rule.new(custom_validation_rule_params)

      if @custom_validation_rule.save
        redirect_to @custom_validation_rule, notice: 'Rule was successfully created.'
      else
        render :new
      end
    end

    # PATCH/PUT /custom_validation/rules/1
    def update
      if @custom_validation_rule.update(custom_validation_rule_params)
        redirect_to @custom_validation_rule, notice: 'Rule was successfully updated.'
      else
        render :edit
      end
    end

    # DELETE /custom_validation/rules/1
    def destroy
      @custom_validation_rule.destroy
      redirect_to custom_validation_rules_url, notice: 'Rule was successfully destroyed.'
    end

    private
      # Use callbacks to share common setup or constraints between actions.
      def set_custom_validation_rule
        @custom_validation_rule = CustomValidation::Rule.find(params[:id])
      end

      # Only allow a trusted parameter "white list" through.
      def custom_validation_rule_params
        params.fetch(:custom_validation_rule, {})
      end
  end
end
