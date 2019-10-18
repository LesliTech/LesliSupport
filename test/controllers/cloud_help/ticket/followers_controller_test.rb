require 'test_helper'

module CloudHelp
  class Ticket::FollowersControllerTest < ActionDispatch::IntegrationTest
    include Engine.routes.url_helpers

    setup do
      @ticket_follower = cloud_help_ticket_followers(:one)
    end

    test "should get index" do
      get ticket_followers_url
      assert_response :success
    end

    test "should get new" do
      get new_ticket_follower_url
      assert_response :success
    end

    test "should create ticket_follower" do
      assert_difference('Ticket::Follower.count') do
        post ticket_followers_url, params: { ticket_follower: {  } }
      end

      assert_redirected_to ticket_follower_url(Ticket::Follower.last)
    end

    test "should show ticket_follower" do
      get ticket_follower_url(@ticket_follower)
      assert_response :success
    end

    test "should get edit" do
      get edit_ticket_follower_url(@ticket_follower)
      assert_response :success
    end

    test "should update ticket_follower" do
      patch ticket_follower_url(@ticket_follower), params: { ticket_follower: {  } }
      assert_redirected_to ticket_follower_url(@ticket_follower)
    end

    test "should destroy ticket_follower" do
      assert_difference('Ticket::Follower.count', -1) do
        delete ticket_follower_url(@ticket_follower)
      end

      assert_redirected_to ticket_followers_url
    end
  end
end
