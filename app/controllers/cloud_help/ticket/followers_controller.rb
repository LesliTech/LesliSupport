require_dependency "cloud_help/application_controller"

module CloudHelp
  class Ticket::FollowersController < ApplicationController
    before_action :set_ticket_follower, only: [:show, :edit, :update, :destroy]

    # GET /ticket/followers
    def index
      @ticket_followers = Ticket::Follower.all
    end

    # GET /ticket/followers/1
    def show
    end

    # GET /ticket/followers/new
    def new
      @ticket_follower = Ticket::Follower.new
    end

    # GET /ticket/followers/1/edit
    def edit
    end

    # POST /ticket/followers
    def create
      @ticket_follower = Ticket::Follower.new(ticket_follower_params)

      if @ticket_follower.save
        redirect_to @ticket_follower, notice: 'Follower was successfully created.'
      else
        render :new
      end
    end

    # PATCH/PUT /ticket/followers/1
    def update
      if @ticket_follower.update(ticket_follower_params)
        redirect_to @ticket_follower, notice: 'Follower was successfully updated.'
      else
        render :edit
      end
    end

    # DELETE /ticket/followers/1
    def destroy
      @ticket_follower.destroy
      redirect_to ticket_followers_url, notice: 'Follower was successfully destroyed.'
    end

    private
      # Use callbacks to share common setup or constraints between actions.
      def set_ticket_follower
        @ticket_follower = Ticket::Follower.find(params[:id])
      end

      # Only allow a trusted parameter "white list" through.
      def ticket_follower_params
        params.fetch(:ticket_follower, {})
      end
  end
end
