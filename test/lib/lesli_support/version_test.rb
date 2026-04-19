require "test_helper"

module LesliSupport
    class VersionTest < ActiveSupport::TestCase
        test "it has a version number" do
            assert(LesliSupport::VERSION)
        end
        test "it has a build number" do
            assert(LesliSupport::BUILD)
        end
    end
end
