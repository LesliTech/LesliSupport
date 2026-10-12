require "test_helper"

module LesliSupport
    class ApplicationRecordTest < ActiveSupport::TestCase
        test "is abstract" do
            assert_predicate LesliSupport::ApplicationRecord, :abstract_class?
        end
    end
end
