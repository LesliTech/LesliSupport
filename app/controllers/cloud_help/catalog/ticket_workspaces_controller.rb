=begin
Copyright (c) 2021, all rights reserved.

All the information provided by this platform is protected by international laws related  to 
industrial property, intellectual property, copyright and relative international laws. 
All intellectual or industrial property rights of the code, texts, trade mark, design, 
pictures and any other information belongs to the owner of this platform.

Without the written permission of the owner, any replication, modification,
transmission, publication is strictly forbidden.

For more information read the license file including with this software.

// · ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~
// · 

=end
require_dependency "cloud_help/application_controller"

module CloudHelp
  class Catalog::TicketWorkspacesController < ApplicationController
      before_action :set_catalog_workspace, only: [:show, :update, :destroy]

      # GET /catalog/workspaces
      def index
          respond_to do |format|
              format.html {}
              format.json do
                  respond_with_successful(Catalog::Workspace.index(current_user, @query))
              end
          end
      end

      # GET /catalog/workspaces/1
      def show
          respond_to do |format|
              format.html {}
              format.json do
                  return respond_with_not_found unless @catalog_workspace
                  return respond_with_successful(@catalog_workspace.show(current_user, @query))
              end
          end
      end

      # GET /catalog/workspaces/new
      def new
      end

      # GET /catalog/workspaces/1/edit
      def edit
      end

      # POST /catalog/workspaces
      def create
          catalog_workspace = Catalog::Workspace.new(catalog_workspace_params)
          if catalog_workspace.save
              respond_with_successful(catalog_workspace)
          else
              respond_with_error(catalog_workspace.errors.full_messages.to_sentence)
          end
      end

      # PATCH/PUT /catalog/workspaces/1
      def update
          return respond_with_not_found unless @catalog_workspace

          if @catalog_workspace.update(catalog_workspace_params)
              respond_with_successful(@catalog_workspace.show(current_user, @query))
          else
              respond_with_error(@catalog_workspace.errors.full_messages.to_sentence)
          end
      end

      # DELETE /catalog/workspaces/1
      def destroy
          return respond_with_not_found unless @catalog_workspace

          if @catalog_workspace.destroy
              respond_with_successful
          else
              respond_with_error(@catalog_workspace.errors.full_messages.to_sentence)
          end
      end

      private

      # Use callbacks to share common setup or constraints between actions.
      def set_catalog_workspace
          @catalog_workspace = current_user.account.catalog_workspaces.find(class_name, params[:id])
      end

      # Only allow a list of trusted parameters through.
      def catalog_workspace_params
          params.require(:catalog_workspace).permit(:id, :name)
      end
  end
end
