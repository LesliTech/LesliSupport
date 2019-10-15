require "application_system_test_case"

module CloudHelp
  class Ticket::DiscussionsTest < ApplicationSystemTestCase
    setup do
      @ticket_discussion = cloud_help_ticket_discussions(:one)
    end

    test "visiting the index" do
      visit ticket_discussions_url
      assert_selector "h1", text: "Ticket/Discussions"
    end

    test "creating a Discussion" do
      visit ticket_discussions_url
      click_on "New Ticket/Discussion"

      click_on "Create Discussion"

      assert_text "Discussion was successfully created"
      click_on "Back"
    end

    test "updating a Discussion" do
      visit ticket_discussions_url
      click_on "Edit", match: :first

      click_on "Update Discussion"

      assert_text "Discussion was successfully updated"
      click_on "Back"
    end

    test "destroying a Discussion" do
      visit ticket_discussions_url
      page.accept_confirm do
        click_on "Destroy", match: :first
      end

      assert_text "Discussion was successfully destroyed"
    end
  end
end
