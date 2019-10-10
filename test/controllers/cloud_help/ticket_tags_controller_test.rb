require 'test_helper'

module CloudHelp
  class TicketTagsControllerTest < ActionDispatch::IntegrationTest
    include Engine.routes.url_helpers

    setup do
      @ticket_tag = cloud_help_ticket_tags(:one)
    end

    test "should get index" do
      get ticket_tags_url
      assert_response :success
    end

    test "should get new" do
      get new_ticket_tag_url
      assert_response :success
    end

    test "should create ticket_tag" do
      assert_difference('TicketTag.count') do
        post ticket_tags_url, params: { ticket_tag: {  } }
      end

      assert_redirected_to ticket_tag_url(TicketTag.last)
    end

    test "should show ticket_tag" do
      get ticket_tag_url(@ticket_tag)
      assert_response :success
    end

    test "should get edit" do
      get edit_ticket_tag_url(@ticket_tag)
      assert_response :success
    end

    test "should update ticket_tag" do
      patch ticket_tag_url(@ticket_tag), params: { ticket_tag: {  } }
      assert_redirected_to ticket_tag_url(@ticket_tag)
    end

    test "should destroy ticket_tag" do
      assert_difference('TicketTag.count', -1) do
        delete ticket_tag_url(@ticket_tag)
      end

      assert_redirected_to ticket_tags_url
    end
  end
end
