require "application_system_test_case"

module CloudHelp
  class TicketTagsTest < ApplicationSystemTestCase
    setup do
      @ticket_tag = cloud_help_ticket_tags(:one)
    end

    test "visiting the index" do
      visit ticket_tags_url
      assert_selector "h1", text: "Ticket Tags"
    end

    test "creating a Ticket tag" do
      visit ticket_tags_url
      click_on "New Ticket Tag"

      click_on "Create Ticket tag"

      assert_text "Ticket tag was successfully created"
      click_on "Back"
    end

    test "updating a Ticket tag" do
      visit ticket_tags_url
      click_on "Edit", match: :first

      click_on "Update Ticket tag"

      assert_text "Ticket tag was successfully updated"
      click_on "Back"
    end

    test "destroying a Ticket tag" do
      visit ticket_tags_url
      page.accept_confirm do
        click_on "Destroy", match: :first
      end

      assert_text "Ticket tag was successfully destroyed"
    end
  end
end
