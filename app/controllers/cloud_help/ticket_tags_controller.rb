require_dependency "cloud_help/application_controller"

module CloudHelp
  class TicketTagsController < ApplicationController
    before_action :set_ticket_tag, only: [:show, :edit, :update, :destroy]

    # GET /ticket_tags
    def index
      @ticket_tags = TicketTag.all
    end

    # GET /ticket_tags/1
    def show
    end

    # GET /ticket_tags/new
    def new
      @ticket_tag = TicketTag.new
    end

    # GET /ticket_tags/1/edit
    def edit
    end

    # POST /ticket_tags
    def create
      @ticket_tag = TicketTag.new(ticket_tag_params)

      if @ticket_tag.save
        redirect_to @ticket_tag, notice: 'Ticket tag was successfully created.'
      else
        render :new
      end
    end

    # PATCH/PUT /ticket_tags/1
    def update
      if @ticket_tag.update(ticket_tag_params)
        redirect_to @ticket_tag, notice: 'Ticket tag was successfully updated.'
      else
        render :edit
      end
    end

    # DELETE /ticket_tags/1
    def destroy
      @ticket_tag.destroy
      redirect_to ticket_tags_url, notice: 'Ticket tag was successfully destroyed.'
    end

    private
      # Use callbacks to share common setup or constraints between actions.
      def set_ticket_tag
        @ticket_tag = TicketTag.find(params[:id])
      end

      # Only allow a trusted parameter "white list" through.
      def ticket_tag_params
        params.fetch(:ticket_tag, {})
      end
  end
end
