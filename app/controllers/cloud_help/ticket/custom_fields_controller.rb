require_dependency "cloud_help/application_controller"

module CloudHelp
  class Ticket::CustomFieldsController < ApplicationController
    before_action :set_ticket_custom_field, only: [:show, :edit, :update, :destroy]

    # GET /ticket/custom_fields
    def index
      @ticket_custom_fields = Ticket::CustomField.all
    end

    # GET /ticket/custom_fields/1
    def show
    end

    # GET /ticket/custom_fields/new
    def new
      @ticket_custom_field = Ticket::CustomField.new
    end

    # GET /ticket/custom_fields/1/edit
    def edit
    end

    # POST /ticket/custom_fields
    def create
      @ticket_custom_field = Ticket::CustomField.new(ticket_custom_field_params)

      if @ticket_custom_field.save
        redirect_to @ticket_custom_field, notice: 'Custom field was successfully created.'
      else
        render :new
      end
    end

    # PATCH/PUT /ticket/custom_fields/1
    def update
      if @ticket_custom_field.update(ticket_custom_field_params)
        redirect_to @ticket_custom_field, notice: 'Custom field was successfully updated.'
      else
        render :edit
      end
    end

    # DELETE /ticket/custom_fields/1
    def destroy
      @ticket_custom_field.destroy
      redirect_to ticket_custom_fields_url, notice: 'Custom field was successfully destroyed.'
    end

    private
      # Use callbacks to share common setup or constraints between actions.
      def set_ticket_custom_field
        @ticket_custom_field = Ticket::CustomField.find(params[:id])
      end

      # Only allow a trusted parameter "white list" through.
      def ticket_custom_field_params
        params.fetch(:ticket_custom_field, {})
      end
  end
end
