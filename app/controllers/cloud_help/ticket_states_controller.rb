require_dependency "cloud_help/application_controller"

module CloudHelp
    class TicketStatesController < ApplicationController
        before_action :set_ticket_state, only: [:update, :destroy]

        # GET /ticket_states
        def index
            respond_to do |format|
                format.html {}
                format.json do
                    ticket_states = current_user.account.help.ticket_states.select(
                        :id,
                        :name,
                        :initial,
                        :final,
                        :created_at,
                        :updated_at
                    ).order(name: :asc)
                    responseWithSuccessful(ticket_states) 
                end
            end
        end

        # GET /ticket_states/1
        def show
            respond_to do |format|
                format.html {}
                format.json do
                    set_ticket_state
                    if @ticket_state
                        responseWithSuccessful(@ticket_state)
                    else
                        responseWithError(I18n.t('cloud_help.controllers.ticket_states.errors.not_found'))
                    end
                end
            end
        end

        # GET /ticket_states/new
        def new
        end

        # GET /ticket_states/1/edit
        def edit
        end

        # POST /ticket_states
        def create
            ticket_state = TicketState.new(ticket_state_params)
            ticket_state.cloud_help_accounts_id = current_user.account.id

            if ticket_state.save
                responseWithSuccessful(ticket_state)
            else
                responseWithError(ticket_state.errors.full_messages.to_sentence)
            end
        end

        # PATCH/PUT /ticket_priorities/1
        def update
            if @ticket_state.update(ticket_state_params)
                responseWithSuccessful(@ticket_state)
            else
                responseWithError(@ticket_state.errors.full_messages.to_sentence)
            end
        end

        # DELETE /ticket_states/1
        def destroy
            unless @ticket_state
                return responseWithError(I18n.t('cloud_help.controllers.ticket_states.errors.not_found'))
            end
            if @ticket_state.destroy
                responseWithSuccessful
            else
                responseWithError(@ticket_state.errors.full_messages.to_sentence)
            end
        end

        private
        # Use callbacks to share common setup or constraints between actions.
        def set_ticket_state
            @ticket_state = TicketState.find_by(
                id: params[:id],
                cloud_help_accounts_id: current_user.account.id
            )
        end

        # Only allow a trusted parameter "white list" through.
        def ticket_state_params
            params.fetch(:ticket_state, {}).permit(:name)
        end
    end
end
