require_dependency "cloud_help/application_controller"

module CloudHelp
  class Ticket::DetailsController < ApplicationController
    before_action :set_ticket_detail, only: [:show, :edit, :update, :destroy]

    # GET /ticket/details
    def index
      @ticket_details = Ticket::Detail.all
    end

    # GET /ticket/details/1
    def show
    end

    # GET /ticket/details/new
    def new
      @ticket_detail = Ticket::Detail.new
    end

    # GET /ticket/details/1/edit
    def edit
    end

    # POST /ticket/details
    def create
      @ticket_detail = Ticket::Detail.new(ticket_detail_params)

      if @ticket_detail.save
        redirect_to @ticket_detail, notice: 'Detail was successfully created.'
      else
        render :new
      end
    end

    # PATCH/PUT /ticket/details/1
    def update
      if @ticket_detail.update(ticket_detail_params)
        redirect_to @ticket_detail, notice: 'Detail was successfully updated.'
      else
        render :edit
      end
    end

    # DELETE /ticket/details/1
    def destroy
      @ticket_detail.destroy
      redirect_to ticket_details_url, notice: 'Detail was successfully destroyed.'
    end

    private
      # Use callbacks to share common setup or constraints between actions.
      def set_ticket_detail
        @ticket_detail = Ticket::Detail.find(params[:id])
      end

      # Only allow a trusted parameter "white list" through.
      def ticket_detail_params
        params.fetch(:ticket_detail, {})
      end
  end
end
