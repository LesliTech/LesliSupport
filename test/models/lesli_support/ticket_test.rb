require "test_helper"

module LesliSupport
    class TicketTest < LesliTesting::ModelTester
        test "inherits from the shared Lesli record" do
            assert_operator LesliSupport::Ticket, :<, Lesli::ApplicationLesliRecord
        end

        test "belongs to its account, owner, and creator" do
            account = LesliSupport::Ticket.reflect_on_association(:account)
            owner = LesliSupport::Ticket.reflect_on_association(:owner)
            user = LesliSupport::Ticket.reflect_on_association(:user)

            assert_equal LesliSupport::Account, account&.klass
            assert_equal "Lesli::User", owner&.class_name
            assert_equal "Lesli::User", user&.class_name
        end

        test "has optional catalog classifications" do
            [ :type, :category, :priority ].each do |association|
                reflection = LesliSupport::Ticket.reflect_on_association(association)

                assert_not_nil reflection
                assert_equal :belongs_to, reflection.macro
                assert_equal "Catalog::Item", reflection.class_name
                assert_equal LesliSupport::Catalog::Item, reflection.klass
                assert reflection.options[:optional]
            end
        end

        test "includes shared ticket item concerns" do
            assert_includes LesliSupport::Ticket.ancestors, Lesli::Items::Tasks
            assert_includes LesliSupport::Ticket.ancestors, Lesli::Items::Activities
            assert_includes LesliSupport::Ticket.ancestors, Lesli::Items::Discussions
            assert_includes LesliSupport::Ticket.ancestors, Lesli::Items::Attachments
        end

        test "has polymorphic attachments" do
            reflection = LesliSupport::Ticket.reflect_on_association(:attachments)

            assert_not_nil reflection
            assert_equal :has_many, reflection.macro
            assert_equal "LesliSupport::Items::Attachment", reflection.class_name
            assert_equal :attachable, reflection.options[:as]
            assert_equal :destroy, reflection.options[:dependent]
        end

        test "only keeps model-level callbacks required by the model" do
            before_create = LesliSupport::Ticket
                ._create_callbacks
                .find { |registered_callback| registered_callback.filter == :before_create_ticket }
            after_save = LesliSupport::Ticket
                ._save_callbacks
                .find { |registered_callback| registered_callback.filter == :after_save_activities }

            assert_not_nil before_create
            assert_equal :before, before_create.kind
            assert_nil after_save
        end
    end
end
