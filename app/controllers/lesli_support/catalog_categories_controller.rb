module LesliSupport
  class CatalogCategoriesController < ApplicationController
    before_action :set_catalog_category, only: %i[ show edit update destroy ]

    # GET /catalog_categories
    def index
      @catalog_categories = CatalogCategory.all
    end

    # GET /catalog_categories/1
    def show
    end

    # GET /catalog_categories/new
    def new
      @catalog_category = CatalogCategory.new
    end

    # GET /catalog_categories/1/edit
    def edit
    end

    # POST /catalog_categories
    def create
      @catalog_category = CatalogCategory.new(catalog_category_params)

      if @catalog_category.save
        redirect_to @catalog_category, notice: "Catalog category was successfully created."
      else
        render :new, status: :unprocessable_entity
      end
    end

    # PATCH/PUT /catalog_categories/1
    def update
      if @catalog_category.update(catalog_category_params)
        redirect_to @catalog_category, notice: "Catalog category was successfully updated.", status: :see_other
      else
        render :edit, status: :unprocessable_entity
      end
    end

    # DELETE /catalog_categories/1
    def destroy
      @catalog_category.destroy
      redirect_to catalog_categories_url, notice: "Catalog category was successfully destroyed.", status: :see_other
    end

    private
      # Use callbacks to share common setup or constraints between actions.
      def set_catalog_category
        @catalog_category = CatalogCategory.find(params[:id])
      end

      # Only allow a list of trusted parameters through.
      def catalog_category_params
        params.fetch(:catalog_category, {})
      end
  end
end
