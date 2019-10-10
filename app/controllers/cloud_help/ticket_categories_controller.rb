require_dependency "cloud_help/application_controller"

module CloudHelp
  class TicketCategoriesController < ApplicationController
    before_action :set_ticket_category, only: [:show, :edit, :update, :destroy]

    # GET /ticket_categories
    def index
      @ticket_categories = TicketCategory.all
    end

    # GET /ticket_categories/1
    def show
    end

    # GET /ticket_categories/new
    def new
      @ticket_category = TicketCategory.new
    end

    # GET /ticket_categories/1/edit
    def edit
    end

    # POST /ticket_categories
    def create
      @ticket_category = TicketCategory.new(ticket_category_params)

      if @ticket_category.save
        redirect_to @ticket_category, notice: 'Ticket category was successfully created.'
      else
        render :new
      end
    end

    # PATCH/PUT /ticket_categories/1
    def update
      if @ticket_category.update(ticket_category_params)
        redirect_to @ticket_category, notice: 'Ticket category was successfully updated.'
      else
        render :edit
      end
    end

    # DELETE /ticket_categories/1
    def destroy
      @ticket_category.destroy
      redirect_to ticket_categories_url, notice: 'Ticket category was successfully destroyed.'
    end

    private
      # Use callbacks to share common setup or constraints between actions.
      def set_ticket_category
        @ticket_category = TicketCategory.find(params[:id])
      end

      # Only allow a trusted parameter "white list" through.
      def ticket_category_params
        params.fetch(:ticket_category, {})
      end
  end
end
