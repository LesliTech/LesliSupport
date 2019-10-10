require 'test_helper'

module CloudHelp
  class Ticket::AttachmentsControllerTest < ActionDispatch::IntegrationTest
    include Engine.routes.url_helpers

    setup do
      @ticket_attachment = cloud_help_ticket_attachments(:one)
    end

    test "should get index" do
      get ticket_attachments_url
      assert_response :success
    end

    test "should get new" do
      get new_ticket_attachment_url
      assert_response :success
    end

    test "should create ticket_attachment" do
      assert_difference('Ticket::Attachment.count') do
        post ticket_attachments_url, params: { ticket_attachment: {  } }
      end

      assert_redirected_to ticket_attachment_url(Ticket::Attachment.last)
    end

    test "should show ticket_attachment" do
      get ticket_attachment_url(@ticket_attachment)
      assert_response :success
    end

    test "should get edit" do
      get edit_ticket_attachment_url(@ticket_attachment)
      assert_response :success
    end

    test "should update ticket_attachment" do
      patch ticket_attachment_url(@ticket_attachment), params: { ticket_attachment: {  } }
      assert_redirected_to ticket_attachment_url(@ticket_attachment)
    end

    test "should destroy ticket_attachment" do
      assert_difference('Ticket::Attachment.count', -1) do
        delete ticket_attachment_url(@ticket_attachment)
      end

      assert_redirected_to ticket_attachments_url
    end
  end
end
