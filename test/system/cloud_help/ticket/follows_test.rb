require "application_system_test_case"

module CloudHelp
  class Ticket::FollowsTest < ApplicationSystemTestCase
    setup do
      @ticket_follow = cloud_help_ticket_follows(:one)
    end

    test "visiting the index" do
      visit ticket_follows_url
      assert_selector "h1", text: "Ticket/Follows"
    end

    test "creating a Follow" do
      visit ticket_follows_url
      click_on "New Ticket/Follow"

      click_on "Create Follow"

      assert_text "Follow was successfully created"
      click_on "Back"
    end

    test "updating a Follow" do
      visit ticket_follows_url
      click_on "Edit", match: :first

      click_on "Update Follow"

      assert_text "Follow was successfully updated"
      click_on "Back"
    end

    test "destroying a Follow" do
      visit ticket_follows_url
      page.accept_confirm do
        click_on "Destroy", match: :first
      end

      assert_text "Follow was successfully destroyed"
    end
  end
end
