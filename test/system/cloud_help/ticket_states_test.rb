require "application_system_test_case"

module CloudHelp
  class TicketStatesTest < ApplicationSystemTestCase
    setup do
      @ticket_state = cloud_help_ticket_states(:one)
    end

    test "visiting the index" do
      visit ticket_states_url
      assert_selector "h1", text: "Ticket States"
    end

    test "creating a Ticket state" do
      visit ticket_states_url
      click_on "New Ticket State"

      click_on "Create Ticket state"

      assert_text "Ticket state was successfully created"
      click_on "Back"
    end

    test "updating a Ticket state" do
      visit ticket_states_url
      click_on "Edit", match: :first

      click_on "Update Ticket state"

      assert_text "Ticket state was successfully updated"
      click_on "Back"
    end

    test "destroying a Ticket state" do
      visit ticket_states_url
      page.accept_confirm do
        click_on "Destroy", match: :first
      end

      assert_text "Ticket state was successfully destroyed"
    end
  end
end
