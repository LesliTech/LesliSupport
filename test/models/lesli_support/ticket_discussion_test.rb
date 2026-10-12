require "test_helper"

module LesliSupport
    class TicketDiscussionTest < ActiveSupport::TestCase
        test "inherits from the shared discussion" do
            assert_operator LesliSupport::Ticket::Discussion, :<, Lesli::Items::Discussion
        end

        test "belongs to its ticket and user" do
            item = LesliSupport::Ticket::Discussion.reflect_on_association(:item)
            user = LesliSupport::Ticket::Discussion.reflect_on_association(:user)

            assert_equal LesliSupport::Ticket, item&.klass
            assert_equal "ticket_id", item&.foreign_key
            assert_equal "Lesli::User", user&.class_name
        end
    end
end
