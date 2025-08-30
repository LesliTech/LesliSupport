class CreateLesliSupportTicketDiscussions < ActiveRecord::Migration[8.0]
  def change
    create_table :lesli_support_ticket_discussions do |t|
      t.timestamps
    end
  end
end
