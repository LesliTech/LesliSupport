module LesliSupport
  class Ticket::ActivitiesController < ApplicationController
    before_action :set_ticket_activity, only: %i[ show edit update destroy ]

    # GET /ticket/activities
    def index
      @ticket_activities = Ticket::Activity.all
    end

    # GET /ticket/activities/1
    def show
    end

    # GET /ticket/activities/new
    def new
      @ticket_activity = Ticket::Activity.new
    end

    # GET /ticket/activities/1/edit
    def edit
    end

    # POST /ticket/activities
    def create
      @ticket_activity = Ticket::Activity.new(ticket_activity_params)

      if @ticket_activity.save
        redirect_to @ticket_activity, notice: "Activity was successfully created."
      else
        render :new, status: :unprocessable_entity
      end
    end

    # PATCH/PUT /ticket/activities/1
    def update
      if @ticket_activity.update(ticket_activity_params)
        redirect_to @ticket_activity, notice: "Activity was successfully updated.", status: :see_other
      else
        render :edit, status: :unprocessable_entity
      end
    end

    # DELETE /ticket/activities/1
    def destroy
      @ticket_activity.destroy!
      redirect_to ticket_activities_path, notice: "Activity was successfully destroyed.", status: :see_other
    end

    private
      # Use callbacks to share common setup or constraints between actions.
      def set_ticket_activity
        @ticket_activity = Ticket::Activity.find(params.expect(:id))
      end

      # Only allow a list of trusted parameters through.
      def ticket_activity_params
        params.fetch(:ticket_activity, {})
      end
  end
end
