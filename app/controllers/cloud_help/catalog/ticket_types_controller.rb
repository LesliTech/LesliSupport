require_dependency "cloud_help/application_controller"

module CloudHelp
  class Catalog::TicketTypesController < ApplicationController
    before_action :set_catalog_ticket_type, only: [:show, :edit, :update, :destroy]

    # GET /catalog/ticket_types
    def index
      @catalog_ticket_types = Catalog::TicketType.all
    end

    # GET /catalog/ticket_types/1
    def show
    end

    # GET /catalog/ticket_types/new
    def new
      @catalog_ticket_type = Catalog::TicketType.new
    end

    # GET /catalog/ticket_types/1/edit
    def edit
    end

    # POST /catalog/ticket_types
    def create
      @catalog_ticket_type = Catalog::TicketType.new(catalog_ticket_type_params)

      if @catalog_ticket_type.save
        redirect_to @catalog_ticket_type, notice: 'Ticket type was successfully created.'
      else
        render :new
      end
    end

    # PATCH/PUT /catalog/ticket_types/1
    def update
      if @catalog_ticket_type.update(catalog_ticket_type_params)
        redirect_to @catalog_ticket_type, notice: 'Ticket type was successfully updated.'
      else
        render :edit
      end
    end

    # DELETE /catalog/ticket_types/1
    def destroy
      @catalog_ticket_type.destroy
      redirect_to catalog_ticket_types_url, notice: 'Ticket type was successfully destroyed.'
    end

    private
      # Use callbacks to share common setup or constraints between actions.
      def set_catalog_ticket_type
        @catalog_ticket_type = Catalog::TicketType.find(params[:id])
      end

      # Only allow a trusted parameter "white list" through.
      def catalog_ticket_type_params
        params.fetch(:catalog_ticket_type, {})
      end
  end
end
