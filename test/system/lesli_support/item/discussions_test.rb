require "application_system_test_case"

module LesliSupport
  class Item::DiscussionsTest < ApplicationSystemTestCase
    setup do
      @item_discussion = lesli_support_item_discussions(:one)
    end

    test "visiting the index" do
      visit item_discussions_url
      assert_selector "h1", text: "Discussions"
    end

    test "should create discussion" do
      visit item_discussions_url
      click_on "New discussion"

      click_on "Create Discussion"

      assert_text "Discussion was successfully created"
      click_on "Back"
    end

    test "should update Discussion" do
      visit item_discussion_url(@item_discussion)
      click_on "Edit this discussion", match: :first

      click_on "Update Discussion"

      assert_text "Discussion was successfully updated"
      click_on "Back"
    end

    test "should destroy Discussion" do
      visit item_discussion_url(@item_discussion)
      click_on "Destroy this discussion", match: :first

      assert_text "Discussion was successfully destroyed"
    end
  end
end
