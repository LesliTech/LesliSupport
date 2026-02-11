require "application_system_test_case"

module LesliSupport
  class Ticket::ActivitiesTest < ApplicationSystemTestCase
    setup do
      @ticket_activity = lesli_support_ticket_activities(:one)
    end

    test "visiting the index" do
      visit ticket_activities_url
      assert_selector "h1", text: "Activities"
    end

    test "should create activity" do
      visit ticket_activities_url
      click_on "New activity"

      click_on "Create Activity"

      assert_text "Activity was successfully created"
      click_on "Back"
    end

    test "should update Activity" do
      visit ticket_activity_url(@ticket_activity)
      click_on "Edit this activity", match: :first

      click_on "Update Activity"

      assert_text "Activity was successfully updated"
      click_on "Back"
    end

    test "should destroy Activity" do
      visit ticket_activity_url(@ticket_activity)
      click_on "Destroy this activity", match: :first

      assert_text "Activity was successfully destroyed"
    end
  end
end
