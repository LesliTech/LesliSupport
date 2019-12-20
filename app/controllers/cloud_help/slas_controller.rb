require_dependency "cloud_help/application_controller"

module CloudHelp
    class SlasController < ApplicationController
        before_action :set_sla, only: [:update, :destroy]

        # GET /slas
        def index
            respond_to do |format|
                format.html {}
                format.json do 
                    slas = current_user.account.help.slas.select(
                        :id,
                        :name,
                        :expected_response_time,
                        :expected_resolution_time,
                        :default,
                        :created_at,
                        :updated_at
                    )
                    responseWithSuccessful(slas)
                end
            end
        end

        # GET /slas/1
        def show
            respond_to do |format|
                format.html {}
                format.json do
                    set_sla
                    if @sla
                        responseWithSuccessful(@sla)
                    else
                        responseWithError(I18n.t('cloud_help.controllers.slas.errors.not_found'))
                    end
                end
            end
        end

        # GET /slas/new
        def new
        end

        # GET /slas/1/edit
        def edit
        end

        # POST /slas
        def create
            sla = Sla.new(sla_params)
            sla.cloud_help_accounts_id = current_user.account.id

            if sla.save
                responseWithSuccessful(sla)
            else
                responseWithError(sla.errors.full_messages.to_sentence)
            end
        end

        # PATCH|PUT /slas/1
        def update
            if @sla.update(sla_params)
                responseWithSuccessful(@sla)
            else
                responseWithError(@sla.errors.full_messages.to_sentence)
            end
        end

        # DELETE /slas/1
        def destroy
            unless @sla
                return responseWithError(I18n.t('cloud_help.controllers.slas.errors.not_found'))
            end
            if @sla.destroy
                responseWithSuccessful
            else
                responseWithError(@sla.errors.full_messages.to_sentence)
            end
        end

        private

        # Use callbacks to share common setup or constraints between actions.
        def set_sla
            @sla = Sla.find_by(
                id: params[:id],
                cloud_help_accounts_id: current_user.account.id
            )
        end

        # Only allow a trusted parameter "white list" through.
        def sla_params
            params.fetch(:sla, {}).permit(
                :name,
                :body,
                :expected_resolution_time,
                :expected_response_time,
                :provider_repercussions,
                :exceptions,
                :default
            )
        end
    end
end
