require 'test_helper'

module CloudHelp
  class Ticket::FilesControllerTest < ActionDispatch::IntegrationTest
    include Engine.routes.url_helpers

    setup do
      @ticket_file = cloud_help_ticket_files(:one)
    end

    test "should get index" do
      get ticket_files_url
      assert_response :success
    end

    test "should get new" do
      get new_ticket_file_url
      assert_response :success
    end

    test "should create ticket_file" do
      assert_difference('Ticket::File.count') do
        post ticket_files_url, params: { ticket_file: {  } }
      end

      assert_redirected_to ticket_file_url(Ticket::File.last)
    end

    test "should show ticket_file" do
      get ticket_file_url(@ticket_file)
      assert_response :success
    end

    test "should get edit" do
      get edit_ticket_file_url(@ticket_file)
      assert_response :success
    end

    test "should update ticket_file" do
      patch ticket_file_url(@ticket_file), params: { ticket_file: {  } }
      assert_redirected_to ticket_file_url(@ticket_file)
    end

    test "should destroy ticket_file" do
      assert_difference('Ticket::File.count', -1) do
        delete ticket_file_url(@ticket_file)
      end

      assert_redirected_to ticket_files_url
    end
  end
end
