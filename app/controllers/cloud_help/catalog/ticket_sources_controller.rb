require_dependency "cloud_help/application_controller"

module CloudHelp
  class Catalog::TicketSourcesController < ApplicationController
    before_action :set_catalog_ticket_source, only: [:show, :edit, :update, :destroy]

    # GET /catalog/ticket_sources
    def index
      @catalog_ticket_sources = Catalog::TicketSource.all
    end

    # GET /catalog/ticket_sources/1
    def show
    end

    # GET /catalog/ticket_sources/new
    def new
      @catalog_ticket_source = Catalog::TicketSource.new
    end

    # GET /catalog/ticket_sources/1/edit
    def edit
    end

    # POST /catalog/ticket_sources
    def create
      @catalog_ticket_source = Catalog::TicketSource.new(catalog_ticket_source_params)

      if @catalog_ticket_source.save
        redirect_to @catalog_ticket_source, notice: 'Ticket source was successfully created.'
      else
        render :new
      end
    end

    # PATCH/PUT /catalog/ticket_sources/1
    def update
      if @catalog_ticket_source.update(catalog_ticket_source_params)
        redirect_to @catalog_ticket_source, notice: 'Ticket source was successfully updated.'
      else
        render :edit
      end
    end

    # DELETE /catalog/ticket_sources/1
    def destroy
      @catalog_ticket_source.destroy
      redirect_to catalog_ticket_sources_url, notice: 'Ticket source was successfully destroyed.'
    end

    private
      # Use callbacks to share common setup or constraints between actions.
      def set_catalog_ticket_source
        @catalog_ticket_source = Catalog::TicketSource.find(params[:id])
      end

      # Only allow a trusted parameter "white list" through.
      def catalog_ticket_source_params
        params.fetch(:catalog_ticket_source, {})
      end
  end
end
