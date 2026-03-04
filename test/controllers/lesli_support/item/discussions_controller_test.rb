require "test_helper"

module LesliSupport
  class Item::DiscussionsControllerTest < ActionDispatch::IntegrationTest
    include Engine.routes.url_helpers

    setup do
      @item_discussion = lesli_support_item_discussions(:one)
    end

    test "should get index" do
      get item_discussions_url
      assert_response :success
    end

    test "should get new" do
      get new_item_discussion_url
      assert_response :success
    end

    test "should create item_discussion" do
      assert_difference("Item::Discussion.count") do
        post item_discussions_url, params: { item_discussion: {} }
      end

      assert_redirected_to item_discussion_url(Item::Discussion.last)
    end

    test "should show item_discussion" do
      get item_discussion_url(@item_discussion)
      assert_response :success
    end

    test "should get edit" do
      get edit_item_discussion_url(@item_discussion)
      assert_response :success
    end

    test "should update item_discussion" do
      patch item_discussion_url(@item_discussion), params: { item_discussion: {} }
      assert_redirected_to item_discussion_url(@item_discussion)
    end

    test "should destroy item_discussion" do
      assert_difference("Item::Discussion.count", -1) do
        delete item_discussion_url(@item_discussion)
      end

      assert_redirected_to item_discussions_url
    end
  end
end
