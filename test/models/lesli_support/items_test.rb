require "test_helper"

module LesliSupport
    class ItemsTest < ActiveSupport::TestCase
        test "uses the shared item models" do
            assert_operator LesliSupport::Items::Activity, :<, Lesli::Items::Activity
            assert_operator LesliSupport::Items::Discussion, :<, Lesli::Items::Discussion
            assert_operator LesliSupport::Items::Task, :<, Lesli::Items::Task
        end
    end
end
