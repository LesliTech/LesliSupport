require_dependency "cloud_help/application_controller"

module CloudHelp
    class TicketTypesController < ApplicationController
        before_action :set_ticket_type, only: [:show, :edit, :update, :destroy]

        # GET /ticket_types
        def index
            ticket_types = current_user.account.help.ticket_types.select(:id, :name, :created_at, :updated_at)
            respond_to do |format|
                format.html { @ticket_types = ticket_types }
                format.json { responseWithSuccessful(ticket_types) }
            end
        end

        # GET /ticket_types/1
        def show
        end

        # GET /ticket_types/new
        def new
        @ticket_type = TicketType.new
        end

        # GET /ticket_types/1/edit
        def edit
        end

        # POST /ticket_types
        def create
        @ticket_type = TicketType.new(ticket_type_params)

        if @ticket_type.save
            redirect_to @ticket_type, notice: 'Ticket type was successfully created.'
        else
            render :new
        end
        end

        # PATCH/PUT /ticket_types/1
        def update
        if @ticket_type.update(ticket_type_params)
            redirect_to @ticket_type, notice: 'Ticket type was successfully updated.'
        else
            render :edit
        end
        end

        # DELETE /ticket_types/1
        def destroy
        @ticket_type.destroy
        redirect_to ticket_types_url, notice: 'Ticket type was successfully destroyed.'
        end

        private
        # Use callbacks to share common setup or constraints between actions.
        def set_ticket_type
            @ticket_type = TicketType.find(params[:id])
        end

        # Only allow a trusted parameter "white list" through.
        def ticket_type_params
            params.fetch(:ticket_type, {})
        end
    end
end
