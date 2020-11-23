require_dependency "cloud_help/application_controller"

module CloudHelp
  class Sla::SubscribersController < ApplicationController
    before_action :set_sla_subscriber, only: [:show, :edit, :update, :destroy]

    # GET /sla/subscribers
    def index
      @sla_subscribers = Sla::Subscriber.all
    end

    # GET /sla/subscribers/1
    def show
    end

    # GET /sla/subscribers/new
    def new
      @sla_subscriber = Sla::Subscriber.new
    end

    # GET /sla/subscribers/1/edit
    def edit
    end

    # POST /sla/subscribers
    def create
      @sla_subscriber = Sla::Subscriber.new(sla_subscriber_params)

      if @sla_subscriber.save
        redirect_to @sla_subscriber, notice: 'Subscriber was successfully created.'
      else
        render :new
      end
    end

    # PATCH/PUT /sla/subscribers/1
    def update
      if @sla_subscriber.update(sla_subscriber_params)
        redirect_to @sla_subscriber, notice: 'Subscriber was successfully updated.'
      else
        render :edit
      end
    end

    # DELETE /sla/subscribers/1
    def destroy
      @sla_subscriber.destroy
      redirect_to sla_subscribers_url, notice: 'Subscriber was successfully destroyed.'
    end

    private
      # Use callbacks to share common setup or constraints between actions.
      def set_sla_subscriber
        @sla_subscriber = Sla::Subscriber.find(params[:id])
      end

      # Only allow a trusted parameter "white list" through.
      def sla_subscriber_params
        params.fetch(:sla_subscriber, {})
      end
  end
end
