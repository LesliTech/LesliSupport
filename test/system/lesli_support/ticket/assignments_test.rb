require "application_system_test_case"

module LesliSupport
  class Ticket::AssignmentsTest < ApplicationSystemTestCase
    setup do
      @ticket_assignment = lesli_support_ticket_assignments(:one)
    end

    test "visiting the index" do
      visit ticket_assignments_url
      assert_selector "h1", text: "Assignments"
    end

    test "should create assignment" do
      visit ticket_assignments_url
      click_on "New assignment"

      click_on "Create Assignment"

      assert_text "Assignment was successfully created"
      click_on "Back"
    end

    test "should update Assignment" do
      visit ticket_assignment_url(@ticket_assignment)
      click_on "Edit this assignment", match: :first

      click_on "Update Assignment"

      assert_text "Assignment was successfully updated"
      click_on "Back"
    end

    test "should destroy Assignment" do
      visit ticket_assignment_url(@ticket_assignment)
      click_on "Destroy this assignment", match: :first

      assert_text "Assignment was successfully destroyed"
    end
  end
end
