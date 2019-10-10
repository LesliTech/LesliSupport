require_dependency "cloud_help/application_controller"

module CloudHelp
  class Ticket::TimelinesController < ApplicationController
    before_action :set_ticket_timeline, only: [:show, :edit, :update, :destroy]

    # GET /ticket/timelines
    def index
      @ticket_timelines = Ticket::Timeline.all
    end

    # GET /ticket/timelines/1
    def show
    end

    # GET /ticket/timelines/new
    def new
      @ticket_timeline = Ticket::Timeline.new
    end

    # GET /ticket/timelines/1/edit
    def edit
    end

    # POST /ticket/timelines
    def create
      @ticket_timeline = Ticket::Timeline.new(ticket_timeline_params)

      if @ticket_timeline.save
        redirect_to @ticket_timeline, notice: 'Timeline was successfully created.'
      else
        render :new
      end
    end

    # PATCH/PUT /ticket/timelines/1
    def update
      if @ticket_timeline.update(ticket_timeline_params)
        redirect_to @ticket_timeline, notice: 'Timeline was successfully updated.'
      else
        render :edit
      end
    end

    # DELETE /ticket/timelines/1
    def destroy
      @ticket_timeline.destroy
      redirect_to ticket_timelines_url, notice: 'Timeline was successfully destroyed.'
    end

    private
      # Use callbacks to share common setup or constraints between actions.
      def set_ticket_timeline
        @ticket_timeline = Ticket::Timeline.find(params[:id])
      end

      # Only allow a trusted parameter "white list" through.
      def ticket_timeline_params
        params.fetch(:ticket_timeline, {})
      end
  end
end
