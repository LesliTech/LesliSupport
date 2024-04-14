module LesliSupport
  class CatalogTypesController < ApplicationController
    before_action :set_catalog_type, only: %i[ show edit update destroy ]

    # GET /catalog_types
    def index
      @catalog_types = CatalogType.all
    end

    # GET /catalog_types/1
    def show
    end

    # GET /catalog_types/new
    def new
      @catalog_type = CatalogType.new
    end

    # GET /catalog_types/1/edit
    def edit
    end

    # POST /catalog_types
    def create
      @catalog_type = CatalogType.new(catalog_type_params)

      if @catalog_type.save
        redirect_to @catalog_type, notice: "Catalog type was successfully created."
      else
        render :new, status: :unprocessable_entity
      end
    end

    # PATCH/PUT /catalog_types/1
    def update
      if @catalog_type.update(catalog_type_params)
        redirect_to @catalog_type, notice: "Catalog type was successfully updated.", status: :see_other
      else
        render :edit, status: :unprocessable_entity
      end
    end

    # DELETE /catalog_types/1
    def destroy
      @catalog_type.destroy
      redirect_to catalog_types_url, notice: "Catalog type was successfully destroyed.", status: :see_other
    end

    private
      # Use callbacks to share common setup or constraints between actions.
      def set_catalog_type
        @catalog_type = CatalogType.find(params[:id])
      end

      # Only allow a list of trusted parameters through.
      def catalog_type_params
        params.fetch(:catalog_type, {})
      end
  end
end
