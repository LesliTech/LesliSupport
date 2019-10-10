require "application_system_test_case"

module CloudHelp
  class Ticket::ActivitiesTest < ApplicationSystemTestCase
    setup do
      @ticket_activity = cloud_help_ticket_activities(:one)
    end

    test "visiting the index" do
      visit ticket_activities_url
      assert_selector "h1", text: "Ticket/Activities"
    end

    test "creating a Activity" do
      visit ticket_activities_url
      click_on "New Ticket/Activity"

      click_on "Create Activity"

      assert_text "Activity was successfully created"
      click_on "Back"
    end

    test "updating a Activity" do
      visit ticket_activities_url
      click_on "Edit", match: :first

      click_on "Update Activity"

      assert_text "Activity was successfully updated"
      click_on "Back"
    end

    test "destroying a Activity" do
      visit ticket_activities_url
      page.accept_confirm do
        click_on "Destroy", match: :first
      end

      assert_text "Activity was successfully destroyed"
    end
  end
end
