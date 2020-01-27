class CreateCloudHelpTicketDiscussions < ActiveRecord::Migration[6.0]
    def change
        table_base_structure = JSON.parse(File.read(Rails.root.join('db','structure','00000005_discussions.json')))
        create_table :cloud_help_ticket_discussions do |t|
            table_base_structure.each do |column|
                t.send(
                    column["type"].parameterize.underscore.to_sym,
                    column["name"].parameterize.underscore.to_sym
                )
            end
            t.timestamps
            #column.type.to_sym,
            #column.name.to_sym,
            #:null => column.null,
            #:limit => column.limit,
            #:default => column.default,
            #:scale => column.scale,
            #:precision => column.precision
        end
        add_reference :cloud_help_ticket_discussions, :cloud_help_ticket_discussions, foreign_key: true, index: { name: "ticket_comments" }
        add_reference :cloud_help_ticket_discussions, :users, foreign_key: true
        add_reference :cloud_help_ticket_discussions, :cloud_help_tickets, foreign_key: true
    end
end
