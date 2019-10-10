require 'test_helper'

module CloudHelp
  class Ticket::ActionsControllerTest < ActionDispatch::IntegrationTest
    include Engine.routes.url_helpers

    setup do
      @ticket_action = cloud_help_ticket_actions(:one)
    end

    test "should get index" do
      get ticket_actions_url
      assert_response :success
    end

    test "should get new" do
      get new_ticket_action_url
      assert_response :success
    end

    test "should create ticket_action" do
      assert_difference('Ticket::Action.count') do
        post ticket_actions_url, params: { ticket_action: {  } }
      end

      assert_redirected_to ticket_action_url(Ticket::Action.last)
    end

    test "should show ticket_action" do
      get ticket_action_url(@ticket_action)
      assert_response :success
    end

    test "should get edit" do
      get edit_ticket_action_url(@ticket_action)
      assert_response :success
    end

    test "should update ticket_action" do
      patch ticket_action_url(@ticket_action), params: { ticket_action: {  } }
      assert_redirected_to ticket_action_url(@ticket_action)
    end

    test "should destroy ticket_action" do
      assert_difference('Ticket::Action.count', -1) do
        delete ticket_action_url(@ticket_action)
      end

      assert_redirected_to ticket_actions_url
    end
  end
end
