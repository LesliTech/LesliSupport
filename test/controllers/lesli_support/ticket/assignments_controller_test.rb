require "test_helper"

module LesliSupport
  class Ticket::AssignmentsControllerTest < ActionDispatch::IntegrationTest
    include Engine.routes.url_helpers

    setup do
      @ticket_assignment = lesli_support_ticket_assignments(:one)
    end

    test "should get index" do
      get ticket_assignments_url
      assert_response :success
    end

    test "should get new" do
      get new_ticket_assignment_url
      assert_response :success
    end

    test "should create ticket_assignment" do
      assert_difference("Ticket::Assignment.count") do
        post ticket_assignments_url, params: { ticket_assignment: {} }
      end

      assert_redirected_to ticket_assignment_url(Ticket::Assignment.last)
    end

    test "should show ticket_assignment" do
      get ticket_assignment_url(@ticket_assignment)
      assert_response :success
    end

    test "should get edit" do
      get edit_ticket_assignment_url(@ticket_assignment)
      assert_response :success
    end

    test "should update ticket_assignment" do
      patch ticket_assignment_url(@ticket_assignment), params: { ticket_assignment: {} }
      assert_redirected_to ticket_assignment_url(@ticket_assignment)
    end

    test "should destroy ticket_assignment" do
      assert_difference("Ticket::Assignment.count", -1) do
        delete ticket_assignment_url(@ticket_assignment)
      end

      assert_redirected_to ticket_assignments_url
    end
  end
end
