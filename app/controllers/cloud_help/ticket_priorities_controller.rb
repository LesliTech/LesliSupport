require_dependency "cloud_help/application_controller"

module CloudHelp
  class TicketPrioritiesController < ApplicationController
    before_action :set_ticket_priority, only: [:show, :edit, :update, :destroy]

    # GET /ticket_priorities
    def index
        tickets_priorities = current_user.account.help.ticket_priorities.select(:id, :name, :weight, :created_at, :updated_at)
        respond_to do |format|
            format.html { @tickets_priorities = tickets_priorities }
            format.json { responseWithSuccessful(tickets_priorities) }
        end
    end

    # GET /ticket_priorities/1
    def show
    end

    # GET /ticket_priorities/new
    def new
      @ticket_priority = TicketPriority.new
    end

    # GET /ticket_priorities/1/edit
    def edit
    end

    # POST /ticket_priorities
    def create
      @ticket_priority = TicketPriority.new(ticket_priority_params)

      if @ticket_priority.save
        redirect_to @ticket_priority, notice: 'Ticket priority was successfully created.'
      else
        render :new
      end
    end

    # PATCH/PUT /ticket_priorities/1
    def update
      if @ticket_priority.update(ticket_priority_params)
        redirect_to @ticket_priority, notice: 'Ticket priority was successfully updated.'
      else
        render :edit
      end
    end

    # DELETE /ticket_priorities/1
    def destroy
      @ticket_priority.destroy
      redirect_to ticket_priorities_url, notice: 'Ticket priority was successfully destroyed.'
    end

    private
      # Use callbacks to share common setup or constraints between actions.
      def set_ticket_priority
        @ticket_priority = TicketPriority.find(params[:id])
      end

      # Only allow a trusted parameter "white list" through.
      def ticket_priority_params
        params.fetch(:ticket_priority, {})
      end
  end
end
