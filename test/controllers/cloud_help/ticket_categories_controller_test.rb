require 'test_helper'

module CloudHelp
  class TicketCategoriesControllerTest < ActionDispatch::IntegrationTest
    include Engine.routes.url_helpers

    setup do
      @ticket_category = cloud_help_ticket_categories(:one)
    end

    test "should get index" do
      get ticket_categories_url
      assert_response :success
    end

    test "should get new" do
      get new_ticket_category_url
      assert_response :success
    end

    test "should create ticket_category" do
      assert_difference('TicketCategory.count') do
        post ticket_categories_url, params: { ticket_category: {  } }
      end

      assert_redirected_to ticket_category_url(TicketCategory.last)
    end

    test "should show ticket_category" do
      get ticket_category_url(@ticket_category)
      assert_response :success
    end

    test "should get edit" do
      get edit_ticket_category_url(@ticket_category)
      assert_response :success
    end

    test "should update ticket_category" do
      patch ticket_category_url(@ticket_category), params: { ticket_category: {  } }
      assert_redirected_to ticket_category_url(@ticket_category)
    end

    test "should destroy ticket_category" do
      assert_difference('TicketCategory.count', -1) do
        delete ticket_category_url(@ticket_category)
      end

      assert_redirected_to ticket_categories_url
    end
  end
end
