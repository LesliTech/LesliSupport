require "application_system_test_case"

module CloudHelp
  class Ticket::DetailsTest < ApplicationSystemTestCase
    setup do
      @ticket_detail = cloud_help_ticket_details(:one)
    end

    test "visiting the index" do
      visit ticket_details_url
      assert_selector "h1", text: "Ticket/Details"
    end

    test "creating a Detail" do
      visit ticket_details_url
      click_on "New Ticket/Detail"

      click_on "Create Detail"

      assert_text "Detail was successfully created"
      click_on "Back"
    end

    test "updating a Detail" do
      visit ticket_details_url
      click_on "Edit", match: :first

      click_on "Update Detail"

      assert_text "Detail was successfully updated"
      click_on "Back"
    end

    test "destroying a Detail" do
      visit ticket_details_url
      page.accept_confirm do
        click_on "Destroy", match: :first
      end

      assert_text "Detail was successfully destroyed"
    end
  end
end
