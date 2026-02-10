
module LesliSupport
    class Dashboard < Lesli::Shared::Dashboard
        COMPONENTS = [
            :tickets_created, 
            :tickets_by_category, 
            :tickets_open, 
            {:latest_tickets => { size: 8, position: 1 }},
        ]
    end
end
