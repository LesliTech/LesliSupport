module LesliSupport
  class Catalog::ItemsController < ApplicationController
    before_action :set_catalog_item, only: %i[ show edit update destroy ]

    # GET /catalog/items
    def index
      @catalog_items = Catalog::Item.all
    end

    # GET /catalog/items/1
    def show
    end

    # GET /catalog/items/new
    def new
      @catalog_item = Catalog::Item.new
    end

    # GET /catalog/items/1/edit
    def edit
    end

    # POST /catalog/items
    def create
      @catalog_item = Catalog::Item.new(catalog_item_params)

      if @catalog_item.save
        redirect_to @catalog_item, notice: "Item was successfully created."
      else
        render :new, status: :unprocessable_entity
      end
    end

    # PATCH/PUT /catalog/items/1
    def update
      if @catalog_item.update(catalog_item_params)
        redirect_to @catalog_item, notice: "Item was successfully updated.", status: :see_other
      else
        render :edit, status: :unprocessable_entity
      end
    end

    # DELETE /catalog/items/1
    def destroy
      @catalog_item.destroy!
      redirect_to catalog_items_url, notice: "Item was successfully destroyed.", status: :see_other
    end

    private
      # Use callbacks to share common setup or constraints between actions.
      def set_catalog_item
        @catalog_item = Catalog::Item.find(params[:id])
      end

      # Only allow a list of trusted parameters through.
      def catalog_item_params
        params.fetch(:catalog_item, {})
      end
  end
end
