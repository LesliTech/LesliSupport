module LesliSupport
    module Items
        class TasksController < Lesli::Items::TasksController
            private

            def allowed_taskable_classes
                [LesliSupport::Ticket]
            end
        end
    end
end
