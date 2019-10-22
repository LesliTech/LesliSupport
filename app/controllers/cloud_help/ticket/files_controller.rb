require_dependency "cloud_help/application_controller"

module CloudHelp
  class Ticket::FilesController < ApplicationController
    before_action :set_ticket_file, only: [:show, :edit, :update, :destroy]

    # GET /ticket/files
    def index
      @ticket_files = Ticket::File.all
    end

    # GET /ticket/files/1
    def show
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
      @ticket_file = Ticket::File.new(ticket_file_params)

      if @ticket_file.save
        redirect_to @ticket_file, notice: 'File was successfully created.'
      else
        render :new
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
        params.fetch(:ticket_file, {})
      end
  end
end