require_dependency "cloud_help/application_controller"

module CloudHelp
    class TicketPrioritiesController < ApplicationController
        before_action :set_ticket_priority, only: [:update, :destroy]

        # GET /ticket_priorities
        def index
            respond_to do |format|
                format.html {}
                format.json do 
                    ticket_priorities = current_user.account.help.ticket_priorities.select(
                        :id,
                        :name,
                        :weight,
                        :created_at,
                        :updated_at
                    )
                    responseWithSuccessful(ticket_priorities)
                end
            end
        end

        # GET /ticket_priorities/1
        def show
            respond_to do |format|
                format.html {}
                format.json do
                    set_ticket_priority
                    if @ticket_priority
                        responseWithSuccessful(@ticket_priority)
                    else
                        responseWithError(I18n.t('cloud_help.controllers.ticket_priorities.errors.not_found'))
                    end
                end
            end
        end

        # GET /ticket_priorities/new
        def new
        end

        # GET /ticket_priorities/1/edit
        def edit
        end

        # POST /ticket_priorities
        def create
            ticket_priority = TicketPriority.new(ticket_priority_params)
            ticket_priority.cloud_help_accounts_id = current_user.account.id

            if ticket_priority.save
                responseWithSuccessful(ticket_priority)
            else
                responseWithError(ticket_priority.errors.full_messages.to_sentence)
            end
        end

        # PATCH/PUT /ticket_priorities/1
        def update
            if @ticket_priority.update(ticket_priority_params)
                responseWithSuccessful(@ticket_priority)
            else
                responseWithError(@ticket_priority.errors.full_messages.to_sentence)
            end
        end

        # DELETE /ticket_priorities/1
        def destroy
            unless @ticket_priority
                return responseWithError(I18n.t('cloud_help.controllers.ticket_priorities.errors.not_found'))
            end
            if @ticket_priority.destroy
                responseWithSuccessful
            else
                responseWithError(@ticket_priority.errors.full_messages.to_sentence)
            end
        end

        private
        # Use callbacks to share common setup or constraints between actions.
        def set_ticket_priority
            @ticket_priority = TicketPriority.find_by(
                id: params[:id],
                cloud_help_accounts_id: current_user.account.id
            )
        end

        # Only allow a trusted parameter "white list" through.
        def ticket_priority_params
            params.fetch(:ticket_priority, {}).permit(:name, :weight)
        end
    end
end
