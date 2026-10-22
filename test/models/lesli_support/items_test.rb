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

        test "configures every item with the support account" do
            item_classes = {
                LesliSupport::Items::Task => "lesli_support_items_tasks",
                LesliSupport::Items::Discussion => "lesli_support_items_discussions",
                LesliSupport::Items::Attachment => "lesli_support_items_attachments"
            }

            item_classes.each do |item_class, table_name|
                account = item_class.reflect_on_association(:account)

                assert_equal table_name, item_class.table_name
                assert_equal "LesliSupport::Account", account.class_name
            end
        end

        test "configures the task data contract" do
            task = LesliSupport::Items::Task
            account = task.reflect_on_association(:account)
            user = task.reflect_on_association(:user)
            taskable = task.reflect_on_association(:taskable)

            assert_nil Lesli::Items::Task.reflect_on_association(:account)
            assert_equal "lesli_support_items_tasks", task.table_name
            assert_equal "LesliSupport::Account", account.class_name
            assert_equal "Lesli::User", user.class_name
            assert taskable.polymorphic?
            assert_equal(
                [ActiveRecord::Validations::PresenceValidator],
                task.validators_on(:title).map(&:class)
            )
            assert_empty task.validators_on(:done)
        end

        test "configures the discussion data contract" do
            discussion = LesliSupport::Items::Discussion
            account = discussion.reflect_on_association(:account)
            author = discussion.reflect_on_association(:author)
            discussable = discussion.reflect_on_association(:discussable)

            assert_nil Lesli::Items::Discussion.reflect_on_association(:account)
            assert_equal "lesli_support_items_discussions", discussion.table_name
            assert_equal "LesliSupport::Account", account.class_name
            assert_equal "Lesli::User", author.class_name
            assert_equal "user_id", author.foreign_key
            assert discussable.polymorphic?
            assert_equal(
                [ActiveRecord::Validations::PresenceValidator],
                discussion.validators_on(:message).map(&:class)
            )
        end

        test "requires a plain-text discussion message" do
            [nil, "   "].each do |message|
                discussion = LesliSupport::Items::Discussion.new(message: message)

                refute discussion.valid?
                assert_includes discussion.errors[:message], "can't be blank"
            end

            discussion = LesliSupport::Items::Discussion.new(
                message: "Follow up with the customer"
            )

            discussion.valid?
            assert_empty discussion.errors[:message]
        end

        test "requires a task title with content" do
            task = LesliSupport::Items::Task.new(title: "   ")

            refute task.valid?
            assert_includes task.errors[:title], "can't be blank"
        end

        test "obtains task ownership from the taskable resource" do
            account = LesliSupport::Account.new
            ticket = LesliSupport::Ticket.new(account: account)

            assert_same account, ticket.lesli_item_account
        end

        test "stores required task ownership without soft deletion" do
            columns = ActiveRecord::Base.connection
                .columns("lesli_support_items_tasks")
                .index_by(&:name)

            assert_not columns["user_id"].null
            assert_not columns["account_id"].null
            assert_not columns.key?("deleted_at")
        end

        test "keeps the activity table name independent from base class loading" do
            activity = LesliSupport::Items::Activity

            assert activity.instance_variable_defined?(:@table_name)
            assert_equal(
                "lesli_support_items_activities",
                activity.instance_variable_get(:@table_name)
            )
            assert_equal "lesli_support_items_activities", activity.table_name
        end

        test "keeps the task table name independent from base class loading" do
            task = LesliSupport::Items::Task

            assert task.instance_variable_defined?(:@table_name)
            assert_equal(
                "lesli_support_items_tasks",
                task.instance_variable_get(:@table_name)
            )
            assert_equal "lesli_support_items_tasks", task.table_name
        end

        test "keeps the discussion table name independent from base class loading" do
            discussion = LesliSupport::Items::Discussion

            assert discussion.instance_variable_defined?(:@table_name)
            assert_equal(
                "lesli_support_items_discussions",
                discussion.instance_variable_get(:@table_name)
            )
            assert_equal "lesli_support_items_discussions",
                discussion.table_name
        end

        test "stores required discussion ownership in the local account" do
            connection = ActiveRecord::Base.connection
            table_name = "lesli_support_items_discussions"
            columns = connection.columns(table_name).index_by(&:name)
            account_foreign_key = connection
                .foreign_keys(table_name)
                .find { |foreign_key| foreign_key.options[:column] == "account_id" }
            resource_index = connection
                .indexes(table_name)
                .find do |index|
                    index.name ==
                        "lesli_support_items_discussions_discussable_type_id"
                end

            assert_not columns["account_id"].null
            assert_not columns["user_id"].null
            assert_not columns["discussable_type"].null
            assert_not columns["discussable_id"].null
            assert_not columns["message"].null
            assert_not columns.key?("deleted_at")
            assert_not_nil account_foreign_key
            assert_not_nil resource_index
            assert_equal "lesli_support_accounts",
                account_foreign_key.to_table
            assert_equal(
                %w[account_id discussable_type discussable_id],
                resource_index.columns
            )
        end

        test "indexes activities for the subject timeline query" do
            index = ActiveRecord::Base.connection
                .indexes("lesli_support_items_activities")
                .find do |candidate|
                    candidate.name == "lesli_support_items_activities_timeline"
                end

            assert_not_nil index
            assert_equal(
                %w[subject_type subject_id deleted_at created_at id],
                index.columns
            )
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
