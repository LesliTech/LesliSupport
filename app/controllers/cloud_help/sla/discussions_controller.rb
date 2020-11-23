require_dependency "cloud_help/application_controller"

module CloudHelp
  class Sla::DiscussionsController < ApplicationController
    before_action :set_sla_discussion, only: [:show, :edit, :update, :destroy]

    # GET /sla/discussions
    def index
      @sla_discussions = Sla::Discussion.all
    end

    # GET /sla/discussions/1
    def show
    end

    # GET /sla/discussions/new
    def new
      @sla_discussion = Sla::Discussion.new
    end

    # GET /sla/discussions/1/edit
    def edit
    end

    # POST /sla/discussions
    def create
      @sla_discussion = Sla::Discussion.new(sla_discussion_params)

      if @sla_discussion.save
        redirect_to @sla_discussion, notice: 'Discussion was successfully created.'
      else
        render :new
      end
    end

    # PATCH/PUT /sla/discussions/1
    def update
      if @sla_discussion.update(sla_discussion_params)
        redirect_to @sla_discussion, notice: 'Discussion was successfully updated.'
      else
        render :edit
      end
    end

    # DELETE /sla/discussions/1
    def destroy
      @sla_discussion.destroy
      redirect_to sla_discussions_url, notice: 'Discussion was successfully destroyed.'
    end

    private
      # Use callbacks to share common setup or constraints between actions.
      def set_sla_discussion
        @sla_discussion = Sla::Discussion.find(params[:id])
      end

      # Only allow a trusted parameter "white list" through.
      def sla_discussion_params
        params.fetch(:sla_discussion, {})
      end
  end
end
