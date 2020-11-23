require_dependency "cloud_help/application_controller"

module CloudHelp
  class Sla::ActivitiesController < ApplicationController
    before_action :set_sla_activity, only: [:show, :edit, :update, :destroy]

    # GET /sla/activities
    def index
      @sla_activities = Sla::Activity.all
    end

    # GET /sla/activities/1
    def show
    end

    # GET /sla/activities/new
    def new
      @sla_activity = Sla::Activity.new
    end

    # GET /sla/activities/1/edit
    def edit
    end

    # POST /sla/activities
    def create
      @sla_activity = Sla::Activity.new(sla_activity_params)

      if @sla_activity.save
        redirect_to @sla_activity, notice: 'Activity was successfully created.'
      else
        render :new
      end
    end

    # PATCH/PUT /sla/activities/1
    def update
      if @sla_activity.update(sla_activity_params)
        redirect_to @sla_activity, notice: 'Activity was successfully updated.'
      else
        render :edit
      end
    end

    # DELETE /sla/activities/1
    def destroy
      @sla_activity.destroy
      redirect_to sla_activities_url, notice: 'Activity was successfully destroyed.'
    end

    private
      # Use callbacks to share common setup or constraints between actions.
      def set_sla_activity
        @sla_activity = Sla::Activity.find(params[:id])
      end

      # Only allow a trusted parameter "white list" through.
      def sla_activity_params
        params.fetch(:sla_activity, {})
      end
  end
end
