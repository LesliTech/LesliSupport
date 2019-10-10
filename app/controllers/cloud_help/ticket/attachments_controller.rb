require_dependency "cloud_help/application_controller"

module CloudHelp
  class Ticket::AttachmentsController < ApplicationController
    before_action :set_ticket_attachment, only: [:show, :edit, :update, :destroy]

    # GET /ticket/attachments
    def index
      @ticket_attachments = Ticket::Attachment.all
    end

    # GET /ticket/attachments/1
    def show
    end

    # GET /ticket/attachments/new
    def new
      @ticket_attachment = Ticket::Attachment.new
    end

    # GET /ticket/attachments/1/edit
    def edit
    end

    # POST /ticket/attachments
    def create
      @ticket_attachment = Ticket::Attachment.new(ticket_attachment_params)

      if @ticket_attachment.save
        redirect_to @ticket_attachment, notice: 'Attachment was successfully created.'
      else
        render :new
      end
    end

    # PATCH/PUT /ticket/attachments/1
    def update
      if @ticket_attachment.update(ticket_attachment_params)
        redirect_to @ticket_attachment, notice: 'Attachment was successfully updated.'
      else
        render :edit
      end
    end

    # DELETE /ticket/attachments/1
    def destroy
      @ticket_attachment.destroy
      redirect_to ticket_attachments_url, notice: 'Attachment was successfully destroyed.'
    end

    private
      # Use callbacks to share common setup or constraints between actions.
      def set_ticket_attachment
        @ticket_attachment = Ticket::Attachment.find(params[:id])
      end

      # Only allow a trusted parameter "white list" through.
      def ticket_attachment_params
        params.fetch(:ticket_attachment, {})
      end
  end
end
