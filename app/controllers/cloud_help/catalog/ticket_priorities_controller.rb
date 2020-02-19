require_dependency "cloud_help/application_controller"

module CloudHelp
  class Catalog::TicketPrioritiesController < ApplicationController
    before_action :set_catalog_ticket_priority, only: [:show, :edit, :update, :destroy]

    # GET /catalog/ticket_priorities
    def index
      @catalog_ticket_priorities = Catalog::TicketPriority.all
    end

    # GET /catalog/ticket_priorities/1
    def show
    end

    # GET /catalog/ticket_priorities/new
    def new
      @catalog_ticket_priority = Catalog::TicketPriority.new
    end

    # GET /catalog/ticket_priorities/1/edit
    def edit
    end

    # POST /catalog/ticket_priorities
    def create
      @catalog_ticket_priority = Catalog::TicketPriority.new(catalog_ticket_priority_params)

      if @catalog_ticket_priority.save
        redirect_to @catalog_ticket_priority, notice: 'Ticket priority was successfully created.'
      else
        render :new
      end
    end

    # PATCH/PUT /catalog/ticket_priorities/1
    def update
      if @catalog_ticket_priority.update(catalog_ticket_priority_params)
        redirect_to @catalog_ticket_priority, notice: 'Ticket priority was successfully updated.'
      else
        render :edit
      end
    end

    # DELETE /catalog/ticket_priorities/1
    def destroy
      @catalog_ticket_priority.destroy
      redirect_to catalog_ticket_priorities_url, notice: 'Ticket priority was successfully destroyed.'
    end

    private
      # Use callbacks to share common setup or constraints between actions.
      def set_catalog_ticket_priority
        @catalog_ticket_priority = Catalog::TicketPriority.find(params[:id])
      end

      # Only allow a trusted parameter "white list" through.
      def catalog_ticket_priority_params
        params.fetch(:catalog_ticket_priority, {})
      end
  end
end
