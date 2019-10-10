require_dependency "cloud_help/application_controller"

module CloudHelp
  class Ticket::FollowsController < ApplicationController
    before_action :set_ticket_follow, only: [:show, :edit, :update, :destroy]

    # GET /ticket/follows
    def index
      @ticket_follows = Ticket::Follow.all
    end

    # GET /ticket/follows/1
    def show
    end

    # GET /ticket/follows/new
    def new
      @ticket_follow = Ticket::Follow.new
    end

    # GET /ticket/follows/1/edit
    def edit
    end

    # POST /ticket/follows
    def create
      @ticket_follow = Ticket::Follow.new(ticket_follow_params)

      if @ticket_follow.save
        redirect_to @ticket_follow, notice: 'Follow was successfully created.'
      else
        render :new
      end
    end

    # PATCH/PUT /ticket/follows/1
    def update
      if @ticket_follow.update(ticket_follow_params)
        redirect_to @ticket_follow, notice: 'Follow was successfully updated.'
      else
        render :edit
      end
    end

    # DELETE /ticket/follows/1
    def destroy
      @ticket_follow.destroy
      redirect_to ticket_follows_url, notice: 'Follow was successfully destroyed.'
    end

    private
      # Use callbacks to share common setup or constraints between actions.
      def set_ticket_follow
        @ticket_follow = Ticket::Follow.find(params[:id])
      end

      # Only allow a trusted parameter "white list" through.
      def ticket_follow_params
        params.fetch(:ticket_follow, {})
      end
  end
end
