class CreateLesliSupportTicketActivities < ActiveRecord::Migration[8.0]
  def change
    create_table :lesli_support_ticket_activities do |t|
      t.timestamps
    end
  end
end
