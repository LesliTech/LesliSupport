module LesliSupport
    module Items
        class AttachmentsController < Lesli::Items::AttachmentsController
            private

            def allowed_attachable_classes
                [LesliSupport::Ticket]
            end
        end
    end
end
