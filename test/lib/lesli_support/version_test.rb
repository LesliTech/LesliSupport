require "test_helper"

module LesliSupport
    class VersionTest < ActiveSupport::TestCase
        test "has a version number" do
            assert_predicate LesliSupport::VERSION, :present?
        end

        test "has a build number" do
            assert_predicate LesliSupport::BUILD, :present?
        end
    end
end
