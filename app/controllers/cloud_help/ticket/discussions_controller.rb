require_dependency "cloud_help/application_controller"

module CloudHelp
    class Ticket::DiscussionsController < ApplicationController
        before_action :set_ticket_discussion, only: [:show, :edit, :update, :destroy]

        # GET /ticket/discussions
        def index
            @ticket_discussions = Ticket::Discussion.all
        end

        # GET /ticket/discussions/1
        def show
        end

        # GET /ticket/discussions/new
        def new
            @ticket_discussion = Ticket::Discussion.new
        end

        # GET /ticket/discussions/1/edit
        def edit
        end

        # POST /ticket/discussions
        def create

            ticket_discussion = Ticket::Discussion.new(ticket_discussion_params)
            if ticket_discussion.save
                CloudBell::NotificationsController.web_notification
                responseWithSuccessful(ticket_discussion)
            else
                responseWithError("Comment not created")
            end

        end

        # PATCH/PUT /ticket/discussions/1
        def update
            if @ticket_discussion.update(ticket_discussion_params)
                redirect_to @ticket_discussion, notice: 'Discussion was successfully updated.'
            else
                render :edit
            end
        end

        # DELETE /ticket/discussions/1
        def destroy
            @ticket_discussion.destroy
            redirect_to ticket_discussions_url, notice: 'Discussion was successfully destroyed.'
        end

        private

        # Use callbacks to share common setup or constraints between actions.
        def set_ticket_discussion
            @ticket_discussion = Ticket::Discussion.find(params[:id])
        end

        # Only allow a trusted parameter "white list" through.
        def ticket_discussion_params
            params.require(:ticket_discussion).permit(:content, :cloud_help_tickets_id)
        end

    end
end
