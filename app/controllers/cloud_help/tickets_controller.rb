require_dependency "cloud_help/application_controller"

module CloudHelp
    class TicketsController < ApplicationController
        before_action :set_ticket, only: [:update]

        # GET /tickets
        def index
            respond_to do |format|
                format.html { }
                format.json do
                    tickets = Ticket.detailed_info(current_user.account.help)
                    responseWithSuccessful(tickets) 
                end
            end
        end

        # GET /tickets/1
        def show
            respond_to do |format|
                format.html { }
                format.json do
                    ticket = Ticket.find_by(
                        id: params[:id],
                        account: current_user.account.help
                    ).detailed_info
                    responseWithSuccessful(ticket)
                end
            end
        end

        # GET /tickets/new
        def new
            @ticket = Ticket.new
        end

        # GET /tickets/1/edit
        def edit
        end

        # POST /tickets
        def create
            ticket = Ticket.new(ticket_params)
            ticket.user = current_user
            ticket.account = current_user.account.help
            ticket.detail.source = TicketSource.cloud_help_source
            ticket.set_workflow

            if ticket.save
                responseWithSuccessful(ticket)
            else
                responseWithError("error creating new ticket", ticket.errors.full_messages)
            end
        end

        # PATCH/PUT /tickets/1
        def update
            if @ticket.update(ticket_params)
                responseWithSuccessful(@ticket)
                CloudCourier::Bell::NotificationJob.perform_now(
                    user: current_user,
                    subject: "The ticket: #{@ticket.id} was successfuly updated",
                    href: "/help/tickets/#{@ticket.id}"
                )
            else
                responseWithError("error on update ticket", @ticket.errors.full_messages)
            end
        end

        # DELETE /tickets/1
        def destroy
            @ticket.destroy
            redirect_to tickets_url, notice: 'Ticket was successfully destroyed.'
        end

        # 

        def discussions
            ticket_discussions = @ticket.discussions.order(id: :desc)
            responseWithSuccessful(ticket_discussions)
        end

        def actions
            ticket_actions = @ticket.actions
            responseWithSuccessful(ticket_actions)
        end

        def files
            ticket_files = @ticket.files
            responseWithSuccessful(ticket_files)
        end

        def activities
            responseWithSuccessful([])
        end

        def api_options
            account = current_user.account
            responseWithSuccessful({
                types: TicketType.where(account: current_user.account.help).select(:id, :name),
                categories: TicketCategory.tree(account),
                priorities: TicketPriority.where(account: current_user.account.help).select(:id, :name)
            })
        end

        private

        def set_ticket
            ticket_id = params[:id] unless params[:id].blank?
            ticket_id = params[:ticket_id] unless params[:ticket_id].blank?
            @ticket = current_user.account.help.ticket.find(ticket_id)
        end

        # Only allow a trusted parameter "white list" through.
        def ticket_params
            params.require(:ticket).permit(
                detail_attributes: [
                    :id,
                    :subject,
                    :description,
                    :tags,
                    :cloud_help_ticket_types_id,
                    :cloud_help_ticket_priorities_id,
                    :cloud_help_ticket_categories_id
                ]
            )
        end

    end
end
