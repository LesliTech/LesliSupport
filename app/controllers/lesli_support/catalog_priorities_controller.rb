module LesliSupport
  class CatalogPrioritiesController < ApplicationController
    before_action :set_catalog_priority, only: %i[ show edit update destroy ]

    # GET /catalog_priorities
    def index
      @catalog_priorities = CatalogPriority.all
    end

    # GET /catalog_priorities/1
    def show
    end

    # GET /catalog_priorities/new
    def new
      @catalog_priority = CatalogPriority.new
    end

    # GET /catalog_priorities/1/edit
    def edit
    end

    # POST /catalog_priorities
    def create
      @catalog_priority = CatalogPriority.new(catalog_priority_params)

      if @catalog_priority.save
        redirect_to @catalog_priority, notice: "Catalog priority was successfully created."
      else
        render :new, status: :unprocessable_entity
      end
    end

    # PATCH/PUT /catalog_priorities/1
    def update
      if @catalog_priority.update(catalog_priority_params)
        redirect_to @catalog_priority, notice: "Catalog priority was successfully updated.", status: :see_other
      else
        render :edit, status: :unprocessable_entity
      end
    end

    # DELETE /catalog_priorities/1
    def destroy
      @catalog_priority.destroy
      redirect_to catalog_priorities_url, notice: "Catalog priority was successfully destroyed.", status: :see_other
    end

    private
      # Use callbacks to share common setup or constraints between actions.
      def set_catalog_priority
        @catalog_priority = CatalogPriority.find(params[:id])
      end

      # Only allow a list of trusted parameters through.
      def catalog_priority_params
        params.fetch(:catalog_priority, {})
      end
  end
end
