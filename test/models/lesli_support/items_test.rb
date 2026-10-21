require "test_helper"

module LesliSupport
    class ItemsTest < ActiveSupport::TestCase
        test "uses the shared item models" do
            assert_operator LesliSupport::Items::Activity, :<, Lesli::Items::Activity
            assert_operator LesliSupport::Items::Attachment, :<, Lesli::Items::Attachment
            assert_operator LesliSupport::Items::Discussion, :<, Lesli::Items::Discussion
            assert_operator LesliSupport::Items::Task, :<, Lesli::Items::Task
        end

        test "configures activity ownership and storage explicitly" do
            activity = LesliSupport::Items::Activity
            actor = activity.reflect_on_association(:actor)
            account = activity.reflect_on_association(:account)
            subject = activity.reflect_on_association(:subject)

            assert_equal "lesli_support_items_activities", activity.table_name
            assert_equal "Lesli::User", actor.class_name
            assert_equal "user_id", actor.foreign_key
            assert_equal "LesliSupport::Account", account.class_name
            assert subject.polymorphic?
        end

        test "configures ticket attachment storage" do
            assert_equal "lesli_support_items_attachments",
                LesliSupport::Items::Attachment.table_name
            assert_equal 25.megabytes,
                LesliSupport::Items::Attachment.lesli_attachment_max_file_size
            assert_includes(
                LesliSupport::Items::Attachment.lesli_attachment_content_types,
                "application/pdf"
            )
            assert_not_nil(
                LesliSupport::Items::Attachment.reflect_on_attachment(:file)
            )
        end

        test "requires an attached file" do
            attachment = LesliSupport::Items::Attachment.new

            refute attachment.valid?
            assert_includes(
                attachment.errors[:file],
                I18n.t("lesli.items.attachments.errors.required")
            )
        end

        test "rejects unsupported file types" do
            attachment = LesliSupport::Items::Attachment.new
            attachment.file.attach(
                io: StringIO.new("executable"),
                filename: "unsafe.exe",
                content_type: "application/x-msdownload"
            )

            refute attachment.valid?
            assert_includes(
                attachment.errors[:file],
                I18n.t("lesli.items.attachments.errors.unsupported_type")
            )
        end
    end
end
