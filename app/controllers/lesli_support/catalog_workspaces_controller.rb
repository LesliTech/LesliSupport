module LesliSupport
  class CatalogWorkspacesController < ApplicationController
    before_action :set_catalog_workspace, only: %i[ show edit update destroy ]

    # GET /catalog_workspaces
    def index
      @catalog_workspaces = CatalogWorkspace.all
    end

    # GET /catalog_workspaces/1
    def show
    end

    # GET /catalog_workspaces/new
    def new
      @catalog_workspace = CatalogWorkspace.new
    end

    # GET /catalog_workspaces/1/edit
    def edit
    end

    # POST /catalog_workspaces
    def create
      @catalog_workspace = CatalogWorkspace.new(catalog_workspace_params)

      if @catalog_workspace.save
        redirect_to @catalog_workspace, notice: "Catalog workspace was successfully created."
      else
        render :new, status: :unprocessable_entity
      end
    end

    # PATCH/PUT /catalog_workspaces/1
    def update
      if @catalog_workspace.update(catalog_workspace_params)
        redirect_to @catalog_workspace, notice: "Catalog workspace was successfully updated.", status: :see_other
      else
        render :edit, status: :unprocessable_entity
      end
    end

    # DELETE /catalog_workspaces/1
    def destroy
      @catalog_workspace.destroy
      redirect_to catalog_workspaces_url, notice: "Catalog workspace was successfully destroyed.", status: :see_other
    end

    private
      # Use callbacks to share common setup or constraints between actions.
      def set_catalog_workspace
        @catalog_workspace = CatalogWorkspace.find(params[:id])
      end

      # Only allow a list of trusted parameters through.
      def catalog_workspace_params
        params.fetch(:catalog_workspace, {})
      end
  end
end
