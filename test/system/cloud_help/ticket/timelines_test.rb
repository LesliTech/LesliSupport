require "application_system_test_case"

module CloudHelp
  class Ticket::TimelinesTest < ApplicationSystemTestCase
    setup do
      @ticket_timeline = cloud_help_ticket_timelines(:one)
    end

    test "visiting the index" do
      visit ticket_timelines_url
      assert_selector "h1", text: "Ticket/Timelines"
    end

    test "creating a Timeline" do
      visit ticket_timelines_url
      click_on "New Ticket/Timeline"

      click_on "Create Timeline"

      assert_text "Timeline was successfully created"
      click_on "Back"
    end

    test "updating a Timeline" do
      visit ticket_timelines_url
      click_on "Edit", match: :first

      click_on "Update Timeline"

      assert_text "Timeline was successfully updated"
      click_on "Back"
    end

    test "destroying a Timeline" do
      visit ticket_timelines_url
      page.accept_confirm do
        click_on "Destroy", match: :first
      end

      assert_text "Timeline was successfully destroyed"
    end
  end
end
