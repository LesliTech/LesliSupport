module LesliSupport
    module Items
        class DiscussionsController < Lesli::Items::DiscussionsController
            private

            def allowed_discussable_classes
                [LesliSupport::Ticket]
            end
        end
    end
end
