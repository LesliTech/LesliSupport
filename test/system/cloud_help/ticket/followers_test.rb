require "application_system_test_case"

module CloudHelp
  class Ticket::FollowersTest < ApplicationSystemTestCase
    setup do
      @ticket_follower = cloud_help_ticket_followers(:one)
    end

    test "visiting the index" do
      visit ticket_followers_url
      assert_selector "h1", text: "Ticket/Followers"
    end

    test "creating a Follower" do
      visit ticket_followers_url
      click_on "New Ticket/Follower"

      click_on "Create Follower"

      assert_text "Follower was successfully created"
      click_on "Back"
    end

    test "updating a Follower" do
      visit ticket_followers_url
      click_on "Edit", match: :first

      click_on "Update Follower"

      assert_text "Follower was successfully updated"
      click_on "Back"
    end

    test "destroying a Follower" do
      visit ticket_followers_url
      page.accept_confirm do
        click_on "Destroy", match: :first
      end

      assert_text "Follower was successfully destroyed"
    end
  end
end
