require_dependency "cloud_help/application_controller"

module CloudHelp
  class TicketSourcesController < ApplicationController
    before_action :set_ticket_source, only: [:show, :edit, :update, :destroy]

    # GET /ticket_sources
    def index
      @ticket_sources = TicketSource.all
    end

    # GET /ticket_sources/1
    def show
    end

    # GET /ticket_sources/new
    def new
      @ticket_source = TicketSource.new
    end

    # GET /ticket_sources/1/edit
    def edit
    end

    # POST /ticket_sources
    def create
      @ticket_source = TicketSource.new(ticket_source_params)

      if @ticket_source.save
        redirect_to @ticket_source, notice: 'Ticket source was successfully created.'
      else
        render :new
      end
    end

    # PATCH/PUT /ticket_sources/1
    def update
      if @ticket_source.update(ticket_source_params)
        redirect_to @ticket_source, notice: 'Ticket source was successfully updated.'
      else
        render :edit
      end
    end

    # DELETE /ticket_sources/1
    def destroy
      @ticket_source.destroy
      redirect_to ticket_sources_url, notice: 'Ticket source was successfully destroyed.'
    end

    private
      # Use callbacks to share common setup or constraints between actions.
      def set_ticket_source
        @ticket_source = TicketSource.find(params[:id])
      end

      # Only allow a trusted parameter "white list" through.
      def ticket_source_params
        params.fetch(:ticket_source, {})
      end
  end
end
