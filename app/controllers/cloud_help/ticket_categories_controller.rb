require_dependency "cloud_help/application_controller"

module CloudHelp
  class TicketCategoriesController < ApplicationController
    before_action :set_ticket_category, only: [:update, :destroy, :api_tree]

    # GET /ticket_categories
    def index
        respond_to do |format|
            format.html {}
            format.json do 
                ticket_categories = TicketCategory.tree(current_user.account)
                responseWithSuccessful(ticket_categories)
            end
        end
    end

    # GET /ticket_categories/1
    def show
        respond_to do |format|
            format.html {}
            format.json do
                set_ticket_category
                if @ticket_category
                    responseWithSuccessful(@ticket_category)
                else
                    responseWithError(I18n.t('cloud_help.controllers.ticket_categories.errors.not_found'))
                end
            end
        end
    end

    # GET /ticket_categories/new
    def new
      @ticket_category = TicketCategory.new
    end

    # GET /ticket_categories/1/edit
    def edit
    end

    # POST /ticket_categories
    def create
        ticket_category = TicketCategory.new(ticket_category_params)
        ticket_category.cloud_help_accounts_id = current_user.account.id
        
        if ticket_category.save
            ticket_category.assign_default_states
            responseWithSuccessful(ticket_category)
        else
            responseWithError(ticket_category.errors.full_messages.to_sentence)
        end
    end

    # PATCH|PUT /ticket_categories/1
    def update
        if @ticket_category.update(ticket_category_params)
            responseWithSuccessful(@ticket_category)
        else
            responseWithError(@ticket_category.errors.full_messages.to_sentence)
        end
    end

    # DELETE /ticket_categories/1
    def destroy
        unless @ticket_category
            return responseWithError(I18n.t('cloud_help.controllers.ticket_categories.errors.not_found'))
        end
        if @ticket_category.destroy
            responseWithSuccessful
        else
            responseWithError(@ticket_category.errors.full_messages.to_sentence)
        end
    end

    # GET /api/ticket_categories/1/tree
    def api_tree
        responseWithSuccessful(@ticket_category.tree)
    end

    private
        # Use callbacks to share common setup or constraints between actions.
        def set_ticket_category
            @ticket_category = TicketCategory.find_by(
                id: params[:id],
                cloud_help_accounts_id: current_user.account.id
            )
        end

        # Only allow a trusted parameter "white list" through.
        def ticket_category_params
            params.fetch(:ticket_category, {}).permit(:name, :parent_id)
        end
  end
end
