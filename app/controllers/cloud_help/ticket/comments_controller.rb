require_dependency "cloud_help/application_controller"

module CloudHelp
    class Ticket::CommentsController < ApplicationController
        before_action :set_ticket_comment, only: [:show, :edit, :update, :destroy]

        # GET /ticket/comments
        def index
            ticket_comments = Ticket::Comment.all.order(created_at: :desc)
            responseWithSuccessful(ticket_comments)
        end

        # GET /ticket/comments/1
        def show
        end

        # GET /ticket/comments/new
        def new
            @ticket_comment = Ticket::Comment.new
        end

        # GET /ticket/comments/1/edit
        def edit
        end

        # POST /ticket/comments
        def create

            ticket_comment = Ticket::Comment.new(ticket_comment_params)

            if ticket_comment.save
                CloudBell::NotificationsController.web_notification
                responseWithSuccessful(ticket_comment)
            else
                responseWithError("Comment not created")
            end

        end

        # PATCH/PUT /ticket/comments/1
        def update
            if @ticket_comment.update(ticket_comment_params)
                redirect_to @ticket_comment, notice: 'Comment was successfully updated.'
            else
                render :edit
            end
        end

        # DELETE /ticket/comments/1
        def destroy
            @ticket_comment.destroy
            redirect_to ticket_comments_url, notice: 'Comment was successfully destroyed.'
        end

        private

        # Use callbacks to share common setup or constraints between actions.
        def set_ticket_comment
            @ticket_comment = Ticket::Comment.find(params[:id])
        end

        # Only allow a trusted parameter "white list" through.
        def ticket_comment_params
            #params.fetch(:ticket_comment, {})
            params.require(:ticket_comment).permit(:content)
        end
    end
end
