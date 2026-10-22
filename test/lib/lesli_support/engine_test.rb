require "test_helper"

module LesliSupport
    class EngineTest < ActiveSupport::TestCase
        test "inherits from Rails engine" do
            assert_operator LesliSupport::Engine, :<, Rails::Engine
        end

        test "isolates the LesliSupport namespace" do
            assert_equal "LesliSupport", LesliSupport::Engine.railtie_namespace.name
        end

        test "defines ticket resource routes" do
            route_names = LesliSupport::Engine.routes.routes.filter_map(&:name)

            assert_includes route_names, "tickets"
            assert_includes route_names, "ticket"
            assert_includes route_names, "ticket_actions"
            assert_includes route_names, "items_discussions"
            assert_includes route_names, "items_attachments"
            assert_includes route_names, "items_attachment"
        end
    end
end
