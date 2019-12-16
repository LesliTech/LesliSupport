require_dependency "cloud_help/application_controller"

module CloudHelp
    class Ticket::FilesController < ApplicationController
        before_action :set_ticket_file, only: [:show]

        include Rails.application.routes.url_helpers

        # GET /tickets/1/files
        def index
            ticket_id = params[:ticket_id]
            @ticket_files = current_user.account.help.tickets.find(ticket_id).files.order(id: :desc)
            responseWithSuccessful(@ticket_files)
        end

        # POST /tickets/1/files
        def create
            ticket_id = params[:ticket_id]
            ticket = current_user.account.help.tickets.find(ticket_id)
            
            ticket_file = ticket.files.build(ticket_file_params)
            ticket_file.name = ticket_file.file.filename if ticket_file.name.blank?
            if ticket_file.save
                responseWithSuccessful
                message = I18n.t(
                    "cloud_help.controllers.ticket.files.notifications.created",
                    :ticket_id => ticket.id
                )
                ticket.notify_subscribers(message, :comment_created)
            else
                responseWithError(@ticket.errors.full_messages.to_sentence)
            end
        end

        # GET /tickets/1/files/1
        def show
            redirect_to rails_blob_path(@ticket_file.file, disposition: "attachment")
        end

        private

        # Use callbacks to share common setup or constraints between actions.
        def set_ticket_file
            @ticket_file = Ticket::File.joins(:ticket).where(
                "cloud_help_ticket_files.id = #{params[:id]}",
                "cloud_help_tickets.cloud_help_tickets_id = #{params[:ticket_id]}",
                "cloud_help_tickets.cloud_help_accounts_id = #{current_user.account.id}"
            ).first
        end

        # Only allow a trusted parameter "white list" through.
        def ticket_file_params
            params.require(:ticket_file).permit(:name, :file)
        end
    end
end
