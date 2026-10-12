require "test_helper"

module LesliSupport
    class DashboardTest < ActiveSupport::TestCase
        test "inherits from the shared dashboard" do
            assert_operator LesliSupport::Dashboard, :<, Lesli::Shared::Dashboard
        end

        test "registers ticket dashboard components" do
            assert_includes LesliSupport::Dashboard::COMPONENTS, :tickets_created
            assert_includes LesliSupport::Dashboard::COMPONENTS, :tickets_by_category
            assert_includes LesliSupport::Dashboard::COMPONENTS, :tickets_open
            assert_includes LesliSupport::Dashboard::COMPONENTS, { latest_tickets: { size: 8, position: 1 } }
        end
    end
end
