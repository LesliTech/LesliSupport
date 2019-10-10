require 'test_helper'

module CloudHelp
  class Ticket::ActivitiesControllerTest < ActionDispatch::IntegrationTest
    include Engine.routes.url_helpers

    setup do
      @ticket_activity = cloud_help_ticket_activities(:one)
    end

    test "should get index" do
      get ticket_activities_url
      assert_response :success
    end

    test "should get new" do
      get new_ticket_activity_url
      assert_response :success
    end

    test "should create ticket_activity" do
      assert_difference('Ticket::Activity.count') do
        post ticket_activities_url, params: { ticket_activity: {  } }
      end

      assert_redirected_to ticket_activity_url(Ticket::Activity.last)
    end

    test "should show ticket_activity" do
      get ticket_activity_url(@ticket_activity)
      assert_response :success
    end

    test "should get edit" do
      get edit_ticket_activity_url(@ticket_activity)
      assert_response :success
    end

    test "should update ticket_activity" do
      patch ticket_activity_url(@ticket_activity), params: { ticket_activity: {  } }
      assert_redirected_to ticket_activity_url(@ticket_activity)
    end

    test "should destroy ticket_activity" do
      assert_difference('Ticket::Activity.count', -1) do
        delete ticket_activity_url(@ticket_activity)
      end

      assert_redirected_to ticket_activities_url
    end
  end
end
