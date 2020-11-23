require_dependency "cloud_help/application_controller"

module CloudHelp
  class Sla::ActionsController < ApplicationController
    before_action :set_sla_action, only: [:show, :edit, :update, :destroy]

    # GET /sla/actions
    def index
      @sla_actions = Sla::Action.all
    end

    # GET /sla/actions/1
    def show
    end

    # GET /sla/actions/new
    def new
      @sla_action = Sla::Action.new
    end

    # GET /sla/actions/1/edit
    def edit
    end

    # POST /sla/actions
    def create
      @sla_action = Sla::Action.new(sla_action_params)

      if @sla_action.save
        redirect_to @sla_action, notice: 'Action was successfully created.'
      else
        render :new
      end
    end

    # PATCH/PUT /sla/actions/1
    def update
      if @sla_action.update(sla_action_params)
        redirect_to @sla_action, notice: 'Action was successfully updated.'
      else
        render :edit
      end
    end

    # DELETE /sla/actions/1
    def destroy
      @sla_action.destroy
      redirect_to sla_actions_url, notice: 'Action was successfully destroyed.'
    end

    private
      # Use callbacks to share common setup or constraints between actions.
      def set_sla_action
        @sla_action = Sla::Action.find(params[:id])
      end

      # Only allow a trusted parameter "white list" through.
      def sla_action_params
        params.fetch(:sla_action, {})
      end
  end
end
