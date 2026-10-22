require "test_helper"

module LesliSupport
    class TicketTaskTest < ActiveSupport::TestCase
        class TicketWithTaskList < LesliSupport::Ticket
            lesli_tasks_setup(
                use: "LesliSupport::Items::Task",
                association_name: :task_list
            )
        end

        setup do
            @core_account = Lesli::Account.create!(
                status: "active",
                name: "Task account",
                email: "tasks-#{SecureRandom.hex(4)}@example.com"
            )
            @creator = Lesli::User.new(
                uid: "TSK-#{SecureRandom.hex(4)}",
                email: "task-user-#{SecureRandom.hex(4)}@example.com",
                active: true,
                account: @core_account
            )
            @creator.save!(validate: false)
            @support_account = @core_account.support ||
                LesliSupport::Account.create!(
                    account: @core_account,
                    name: "Support"
                )
            @ticket = create_ticket
        end

        test "add_task creates and returns the task" do
            task = @ticket.add_task!(
                creator: @creator,
                title: "Follow up with customer"
            )

            assert_predicate task, :persisted?
            assert_equal @ticket, task.taskable
            assert_equal @support_account, task.account
            assert_equal @creator, task.user
            assert_equal "Follow up with customer", task.title
            assert_equal task, @ticket.tasks.first
        end

        test "add_task uses the configured association" do
            ticket = TicketWithTaskList.find(@ticket.id)
            ticket.define_singleton_method(:tasks) do
                raise "add_task! used the default association"
            end

            task = ticket.add_task!(
                creator: @creator,
                title: "Review the response"
            )

            assert_equal :task_list, ticket.class.lesli_tasks_association_name
            assert_equal ticket, task.taskable
            assert_includes ticket.task_list, task
        end

        test "add_task raises when the task is invalid" do
            assert_no_difference("LesliSupport::Items::Task.count") do
                assert_raises(ActiveRecord::RecordInvalid) do
                    @ticket.add_task!(creator: @creator, title: "   ")
                end
            end
        end

        private

        def create_ticket
            now = Time.current
            result = LesliSupport::Ticket.insert_all!([{
                account_id: @support_account.id,
                owner_id: @creator.id,
                user_id: @creator.id,
                subject: "Task API test",
                uid: "TKT-#{SecureRandom.hex(4)}",
                created_at: now,
                updated_at: now
            }])

            LesliSupport::Ticket.find(result.rows.first.first)
        end
    end
end
