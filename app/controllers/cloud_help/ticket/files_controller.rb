require_dependency "cloud_help/application_controller"

module CloudHelp
    class Ticket::FilesController < ApplicationController
        before_action :set_ticket_file, only: [:show, :edit, :update, :destroy]

        include Rails.application.routes.url_helpers

        # GET /ticket/files
        def index
            @ticket_files = Ticket::File.all
        end

        # GET /ticket/files/1
        def show
            #download link
            redirect_to rails_blob_path(@ticket_file.file, disposition: "attachment")
        end

        # GET /ticket/files/new
        def new
            @ticket_file = Ticket::File.new
        end

        # GET /ticket/files/1/edit
        def edit
        end

        # POST /ticket/files
        def create
            ticket_file = Ticket::File.new(ticket_file_params)

            # use file name if custom name was not set
            ticket_file.name = ticket_file.file.filename if ticket_file.name.blank?

            if ticket_file.save
                responseWithSuccessful(ticket_file)
            else
                responseWithError("File not created", ticket_file.errors.full_messages)
            end
        end

        # PATCH/PUT /ticket/files/1
        def update
            if @ticket_file.update(ticket_file_params)
                redirect_to @ticket_file, notice: 'File was successfully updated.'
            else
                render :edit
            end
        end

        # DELETE /ticket/files/1
        def destroy
            @ticket_file.destroy
            redirect_to ticket_files_url, notice: 'File was successfully destroyed.'
        end

        private

        # Use callbacks to share common setup or constraints between actions.
        def set_ticket_file
            @ticket_file = Ticket::File.find(params[:id])
        end

        # Only allow a trusted parameter "white list" through.
        def ticket_file_params
            params.require(:ticket_file).permit(:name, :file, :cloud_help_tickets_id)
        end
    end
end
