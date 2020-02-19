require_dependency "cloud_help/application_controller"

module CloudHelp
  class Catalog::TicketCategoriesController < ApplicationController
    before_action :set_catalog_ticket_category, only: [:show, :edit, :update, :destroy]

    # GET /catalog/ticket_categories
    def index
      @catalog_ticket_categories = Catalog::TicketCategory.all
    end

    # GET /catalog/ticket_categories/1
    def show
    end

    # GET /catalog/ticket_categories/new
    def new
      @catalog_ticket_category = Catalog::TicketCategory.new
    end

    # GET /catalog/ticket_categories/1/edit
    def edit
    end

    # POST /catalog/ticket_categories
    def create
      @catalog_ticket_category = Catalog::TicketCategory.new(catalog_ticket_category_params)

      if @catalog_ticket_category.save
        redirect_to @catalog_ticket_category, notice: 'Ticket category was successfully created.'
      else
        render :new
      end
    end

    # PATCH/PUT /catalog/ticket_categories/1
    def update
      if @catalog_ticket_category.update(catalog_ticket_category_params)
        redirect_to @catalog_ticket_category, notice: 'Ticket category was successfully updated.'
      else
        render :edit
      end
    end

    # DELETE /catalog/ticket_categories/1
    def destroy
      @catalog_ticket_category.destroy
      redirect_to catalog_ticket_categories_url, notice: 'Ticket category was successfully destroyed.'
    end

    private
      # Use callbacks to share common setup or constraints between actions.
      def set_catalog_ticket_category
        @catalog_ticket_category = Catalog::TicketCategory.find(params[:id])
      end

      # Only allow a trusted parameter "white list" through.
      def catalog_ticket_category_params
        params.fetch(:catalog_ticket_category, {})
      end
  end
end
