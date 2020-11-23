require_dependency "cloud_help/application_controller"

module CloudHelp
  class Sla::FilesController < ApplicationController
    before_action :set_sla_file, only: [:show, :edit, :update, :destroy]

    # GET /sla/files
    def index
      @sla_files = Sla::File.all
    end

    # GET /sla/files/1
    def show
    end

    # GET /sla/files/new
    def new
      @sla_file = Sla::File.new
    end

    # GET /sla/files/1/edit
    def edit
    end

    # POST /sla/files
    def create
      @sla_file = Sla::File.new(sla_file_params)

      if @sla_file.save
        redirect_to @sla_file, notice: 'File was successfully created.'
      else
        render :new
      end
    end

    # PATCH/PUT /sla/files/1
    def update
      if @sla_file.update(sla_file_params)
        redirect_to @sla_file, notice: 'File was successfully updated.'
      else
        render :edit
      end
    end

    # DELETE /sla/files/1
    def destroy
      @sla_file.destroy
      redirect_to sla_files_url, notice: 'File was successfully destroyed.'
    end

    private
      # Use callbacks to share common setup or constraints between actions.
      def set_sla_file
        @sla_file = Sla::File.find(params[:id])
      end

      # Only allow a trusted parameter "white list" through.
      def sla_file_params
        params.fetch(:sla_file, {})
      end
  end
end
