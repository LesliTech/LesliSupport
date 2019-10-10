require "application_system_test_case"

module CloudHelp
  class TicketCategoriesTest < ApplicationSystemTestCase
    setup do
      @ticket_category = cloud_help_ticket_categories(:one)
    end

    test "visiting the index" do
      visit ticket_categories_url
      assert_selector "h1", text: "Ticket Categories"
    end

    test "creating a Ticket category" do
      visit ticket_categories_url
      click_on "New Ticket Category"

      click_on "Create Ticket category"

      assert_text "Ticket category was successfully created"
      click_on "Back"
    end

    test "updating a Ticket category" do
      visit ticket_categories_url
      click_on "Edit", match: :first

      click_on "Update Ticket category"

      assert_text "Ticket category was successfully updated"
      click_on "Back"
    end

    test "destroying a Ticket category" do
      visit ticket_categories_url
      page.accept_confirm do
        click_on "Destroy", match: :first
      end

      assert_text "Ticket category was successfully destroyed"
    end
  end
end
