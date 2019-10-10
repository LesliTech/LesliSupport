require_dependency "cloud_help/application_controller"

module CloudHelp
  class SlasController < ApplicationController
    before_action :set_sla, only: [:show, :edit, :update, :destroy]

    # GET /slas
    def index
      @slas = Sla.all
    end

    # GET /slas/1
    def show
    end

    # GET /slas/new
    def new
      @sla = Sla.new
    end

    # GET /slas/1/edit
    def edit
    end

    # POST /slas
    def create
      @sla = Sla.new(sla_params)

      if @sla.save
        redirect_to @sla, notice: 'Sla was successfully created.'
      else
        render :new
      end
    end

    # PATCH/PUT /slas/1
    def update
      if @sla.update(sla_params)
        redirect_to @sla, notice: 'Sla was successfully updated.'
      else
        render :edit
      end
    end

    # DELETE /slas/1
    def destroy
      @sla.destroy
      redirect_to slas_url, notice: 'Sla was successfully destroyed.'
    end

    private
      # Use callbacks to share common setup or constraints between actions.
      def set_sla
        @sla = Sla.find(params[:id])
      end

      # Only allow a trusted parameter "white list" through.
      def sla_params
        params.fetch(:sla, {})
      end
  end
end
