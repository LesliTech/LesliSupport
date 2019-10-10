require_dependency "cloud_help/application_controller"

module CloudHelp
  class TicketStatesController < ApplicationController
    before_action :set_ticket_state, only: [:show, :edit, :update, :destroy]

    # GET /ticket_states
    def index
      @ticket_states = TicketState.all
    end

    # GET /ticket_states/1
    def show
    end

    # GET /ticket_states/new
    def new
      @ticket_state = TicketState.new
    end

    # GET /ticket_states/1/edit
    def edit
    end

    # POST /ticket_states
    def create
      @ticket_state = TicketState.new(ticket_state_params)

      if @ticket_state.save
        redirect_to @ticket_state, notice: 'Ticket state was successfully created.'
      else
        render :new
      end
    end

    # PATCH/PUT /ticket_states/1
    def update
      if @ticket_state.update(ticket_state_params)
        redirect_to @ticket_state, notice: 'Ticket state was successfully updated.'
      else
        render :edit
      end
    end

    # DELETE /ticket_states/1
    def destroy
      @ticket_state.destroy
      redirect_to ticket_states_url, notice: 'Ticket state was successfully destroyed.'
    end

    private
      # Use callbacks to share common setup or constraints between actions.
      def set_ticket_state
        @ticket_state = TicketState.find(params[:id])
      end

      # Only allow a trusted parameter "white list" through.
      def ticket_state_params
        params.fetch(:ticket_state, {})
      end
  end
end
