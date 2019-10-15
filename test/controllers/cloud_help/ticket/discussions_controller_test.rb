require 'test_helper'

module CloudHelp
  class Ticket::DiscussionsControllerTest < ActionDispatch::IntegrationTest
    include Engine.routes.url_helpers

    setup do
      @ticket_discussion = cloud_help_ticket_discussions(:one)
    end

    test "should get index" do
      get ticket_discussions_url
      assert_response :success
    end

    test "should get new" do
      get new_ticket_discussion_url
      assert_response :success
    end

    test "should create ticket_discussion" do
      assert_difference('Ticket::Discussion.count') do
        post ticket_discussions_url, params: { ticket_discussion: {  } }
      end

      assert_redirected_to ticket_discussion_url(Ticket::Discussion.last)
    end

    test "should show ticket_discussion" do
      get ticket_discussion_url(@ticket_discussion)
      assert_response :success
    end

    test "should get edit" do
      get edit_ticket_discussion_url(@ticket_discussion)
      assert_response :success
    end

    test "should update ticket_discussion" do
      patch ticket_discussion_url(@ticket_discussion), params: { ticket_discussion: {  } }
      assert_redirected_to ticket_discussion_url(@ticket_discussion)
    end

    test "should destroy ticket_discussion" do
      assert_difference('Ticket::Discussion.count', -1) do
        delete ticket_discussion_url(@ticket_discussion)
      end

      assert_redirected_to ticket_discussions_url
    end
  end
end
