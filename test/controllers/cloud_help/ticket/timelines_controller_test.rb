require 'test_helper'

module CloudHelp
  class Ticket::TimelinesControllerTest < ActionDispatch::IntegrationTest
    include Engine.routes.url_helpers

    setup do
      @ticket_timeline = cloud_help_ticket_timelines(:one)
    end

    test "should get index" do
      get ticket_timelines_url
      assert_response :success
    end

    test "should get new" do
      get new_ticket_timeline_url
      assert_response :success
    end

    test "should create ticket_timeline" do
      assert_difference('Ticket::Timeline.count') do
        post ticket_timelines_url, params: { ticket_timeline: {  } }
      end

      assert_redirected_to ticket_timeline_url(Ticket::Timeline.last)
    end

    test "should show ticket_timeline" do
      get ticket_timeline_url(@ticket_timeline)
      assert_response :success
    end

    test "should get edit" do
      get edit_ticket_timeline_url(@ticket_timeline)
      assert_response :success
    end

    test "should update ticket_timeline" do
      patch ticket_timeline_url(@ticket_timeline), params: { ticket_timeline: {  } }
      assert_redirected_to ticket_timeline_url(@ticket_timeline)
    end

    test "should destroy ticket_timeline" do
      assert_difference('Ticket::Timeline.count', -1) do
        delete ticket_timeline_url(@ticket_timeline)
      end

      assert_redirected_to ticket_timelines_url
    end
  end
end
