require 'test_helper'

module CloudHelp
  class Ticket::FollowsControllerTest < ActionDispatch::IntegrationTest
    include Engine.routes.url_helpers

    setup do
      @ticket_follow = cloud_help_ticket_follows(:one)
    end

    test "should get index" do
      get ticket_follows_url
      assert_response :success
    end

    test "should get new" do
      get new_ticket_follow_url
      assert_response :success
    end

    test "should create ticket_follow" do
      assert_difference('Ticket::Follow.count') do
        post ticket_follows_url, params: { ticket_follow: {  } }
      end

      assert_redirected_to ticket_follow_url(Ticket::Follow.last)
    end

    test "should show ticket_follow" do
      get ticket_follow_url(@ticket_follow)
      assert_response :success
    end

    test "should get edit" do
      get edit_ticket_follow_url(@ticket_follow)
      assert_response :success
    end

    test "should update ticket_follow" do
      patch ticket_follow_url(@ticket_follow), params: { ticket_follow: {  } }
      assert_redirected_to ticket_follow_url(@ticket_follow)
    end

    test "should destroy ticket_follow" do
      assert_difference('Ticket::Follow.count', -1) do
        delete ticket_follow_url(@ticket_follow)
      end

      assert_redirected_to ticket_follows_url
    end
  end
end
