require_dependency "cloud_help/application_controller"

module CloudHelp
    class TicketTypesController < ApplicationController
        before_action :set_ticket_type, only: [:show, :edit, :update, :destroy, :api_show]

        # GET /ticket_types
        def index
            respond_to do |format|
                format.html {}
                format.json do
                    ticket_types = current_user.account.help.ticket_types.select(
                        :id,
                        :name,
                        :created_at,
                        :updated_at
                    )
                    responseWithSuccessful(ticket_types) 
                end
            end
        end

        # GET /ticket_types/1
        def show
        end

        # GET /api/ticket_types/1
        def api_show
            responseWithSuccessful(@ticket_type)
        end

        # GET /ticket_types/new
        def new
        end

        # GET /ticket_types/1/edit
        def edit
        end

        # POST /ticket_types
        def create
            ticket_type = TicketType.new(ticket_type_params)
            ticket_type.cloud_help_accounts_id = current_user.account.id

            if ticket_type.save
                ticket_type.assign_default_states
                responseWithSuccessful(ticket_type)
            else
                responseWithError(ticket_type.errors.full_messages.to_sentence)
            end
        end

        # PATCH/PUT /ticket_priorities/1
        def update
            if @ticket_type.update(ticket_type_params)
                responseWithSuccessful(@ticket_type)
            else
                responseWithError(@ticket_type.errors.full_messages.to_sentence)
            end
        end

        # DELETE /ticket_types/1
        def destroy
            if @ticket_type.destroy
                responseWithSuccessful
            else
                responseWithError(@ticket_type.errors.full_messages.to_sentence)
            end
        end

        private
        # Use callbacks to share common setup or constraints between actions.
        def set_ticket_type
            @ticket_type = TicketType.find_by(
                id: params[:id],
                cloud_help_accounts_id: current_user.account.id
            )
        end

        # Only allow a trusted parameter "white list" through.
        def ticket_type_params
            params.fetch(:ticket_type, {}).permit(:name)
        end
    end
end
