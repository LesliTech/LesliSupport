module LesliSupport
    class Ticket::AssignmentsController < ApplicationController
        before_action :set_ticket, only: %i[create]

        def create
            new_agent = current_user.account.users.find(ticket_assignment_params[:user_id])

            ActiveRecord::Base.transaction do
                @ticket.assignments
                .where(unassigned_at: nil)
                .update_all(unassigned_at: Time.current)

                @ticket.assignments.create!(
                    user: new_agent,
                    assigned_at: Time.current
                )

                @ticket.discussions.create!(
                    message: "#{new_agent.name} was assgined",
                    user_id: new_agent.id
                )
            end

            respond_with_lesli(
                turbo: stream_notification_success("Agent assigned")
            )

        # rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotFound
        #     respond_with_lesli(
        #         turbo: stream_notification_danger("Error assigning agent")
        #     )
        end

        private

        def set_ticket
        @ticket = current_user.account.support.tickets.find(params[:ticket_id])
        end

        def ticket_assignment_params
        params.require(:ticket_assignment).permit(:user_id)
        end
    end
end
