require_dependency "cloud_help/application_controller"

module CloudHelp
  class TicketCategoriesController < ApplicationController
    before_action :set_ticket_category, only: [:show, :edit, :update, :destroy]

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
        if params[:ticket_category][:parent_id]
            parent_category = TicketCategory.find_by(
                id: params[:ticket_category][:parent_id],
                cloud_help_accounts_id: current_user.account.id
            )
            unless parent_category
                return responseWithError(I18n.t('cloud_help.controllers.ticket_categories.create.errors.parent_not_found'))
            end
            ticket_category.parent = parent_category
        end
        
        if ticket_category.save
            responseWithSuccessful(ticket_category)
        else
            responseWithError(ticket_category.errors.full_messages.to_sentence)
        end
    end

    # PATCH/PUT /ticket_categories/1
    def update
        if @ticket_category.update(ticket_category_params)
            redirect_to @ticket_category, notice: 'Ticket category was successfully updated.'
        else
            render :edit
        end
    end

    # DELETE /ticket_categories/1
    def destroy
        @ticket_category.destroy
        redirect_to ticket_categories_url, notice: 'Ticket category was successfully destroyed.'
    end

    private
        # Use callbacks to share common setup or constraints between actions.
        def set_ticket_category
            @ticket_category = TicketCategory.find(params[:id])
        end

        # Only allow a trusted parameter "white list" through.
        def ticket_category_params
            params.fetch(:ticket_category, {}).permit(:name)
        end
  end
end
