require 'test_helper'

module CloudHelp
  class TicketStatesControllerTest < ActionDispatch::IntegrationTest
    include Engine.routes.url_helpers

    setup do
      @ticket_state = cloud_help_ticket_states(:one)
    end

    test "should get index" do
      get ticket_states_url
      assert_response :success
    end

    test "should get new" do
      get new_ticket_state_url
      assert_response :success
    end

    test "should create ticket_state" do
      assert_difference('TicketState.count') do
        post ticket_states_url, params: { ticket_state: {  } }
      end

      assert_redirected_to ticket_state_url(TicketState.last)
    end

    test "should show ticket_state" do
      get ticket_state_url(@ticket_state)
      assert_response :success
    end

    test "should get edit" do
      get edit_ticket_state_url(@ticket_state)
      assert_response :success
    end

    test "should update ticket_state" do
      patch ticket_state_url(@ticket_state), params: { ticket_state: {  } }
      assert_redirected_to ticket_state_url(@ticket_state)
    end

    test "should destroy ticket_state" do
      assert_difference('TicketState.count', -1) do
        delete ticket_state_url(@ticket_state)
      end

      assert_redirected_to ticket_states_url
    end
  end
end
