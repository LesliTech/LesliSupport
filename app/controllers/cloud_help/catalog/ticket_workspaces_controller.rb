=begin
Copyright (c) 2022, all rights reserved.

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
        before_action :set_workspace, only: [:show, :update, :destroy]

        # GET /catalog/workspaces
        def index
            respond_to do |format|
                format.html {}
                format.json do
                    respond_with_pagination(Catalog::TicketWorkspace.index(current_user, @query))
                end
            end
        end

        # GET /catalog/workspaces/1
        def show
            respond_to do |format|
                format.html {}
                format.json do
                    return respond_with_not_found unless @workspace
                    return respond_with_successful(@workspace.show(current_user, @query))
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
            ticket_workspace = current_user.account.help.ticket_workspaces.new(workspace_params)
            if ticket_workspace.save
                respond_with_successful(ticket_workspace)
            else
                respond_with_error(ticket_workspace.errors.full_messages.to_sentence)
            end
        end

        # PATCH/PUT /catalog/workspaces/1
        def update
            return respond_with_not_found unless @workspace

            if @workspace.update(workspace_params)
                respond_with_successful(@workspace.show(current_user, @query))
            else
                respond_with_error(@workspace.errors.full_messages.to_sentence)
            end
        end

        # DELETE /catalog/workspaces/1
        def destroy
            return respond_with_not_found unless @workspace

            if @workspace.destroy
                respond_with_successful
            else
                respond_with_error(@workspace.errors.full_messages.to_sentence)
            end
        end

        private

        # Use callbacks to share common setup or constraints between actions.
        def set_workspace
            @workspace = current_user.account.help.ticket_workspaces.find_by_id(params[:id])
        end

        # Only allow a list of trusted parameters through.
        def workspace_params
            params.require(:ticket_workspace).permit(:name, :default)
        end
    end
end
