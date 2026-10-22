require "test_helper"

module LesliSupport
    module Items
        class TasksControllerTest < ActionController::TestCase
            tests LesliSupport::Items::TasksController

            setup do
                @routes = LesliSupport::Engine.routes
                @account = Lesli::Account.create!(
                    status: "active",
                    name: "Task account",
                    email: "tasks-#{SecureRandom.hex(4)}@example.com"
                )
                @user = Lesli::User.new(
                    uid: "TSK-#{SecureRandom.hex(4)}",
                    email: "tasks-user-#{SecureRandom.hex(4)}@example.com",
                    active: true,
                    account: @account
                )
                @user.save!(validate: false)
                @support_account = @account.support ||
                    LesliSupport::Account.create!(
                        account: @account,
                        name: "Support"
                    )
                @ticket = create_ticket

                user = @user
                @controller.define_singleton_method(:current_user) { user }
                @controller.define_singleton_method(:authenticate_request) { true }
                @controller.define_singleton_method(:authorize_request) { true }
                @controller.define_singleton_method(:log_requests) { true }
            end

            test "creates a task with ownership from its taskable" do
                assert_difference("LesliSupport::Items::Task.count", 1) do
                    post(
                        :create,
                        params: {
                            taskable_type: "LesliSupport::Ticket",
                            taskable_id: @ticket.id,
                            lesli_support_items_task: {
                                title: "Follow up with the customer"
                            }
                        },
                        format: :turbo_stream
                    )
                end

                assert_response :created
                assert_includes response.body,
                    I18n.t("lesli.items.tasks.created")
                assert_equal "", task_title_input["value"].to_s

                task = LesliSupport::Items::Task.last
                assert_equal @support_account, task.account
                assert_equal @user, task.user
                assert_equal @ticket, task.taskable
                assert_equal "Follow up with the customer", task.title
            end

            test "does not create an invalid task" do
                assert_no_difference("LesliSupport::Items::Task.count") do
                    post(
                        :create,
                        params: {
                            taskable_type: "LesliSupport::Ticket",
                            taskable_id: @ticket.id,
                            lesli_support_items_task: { title: "   " }
                        },
                        format: :turbo_stream
                    )
                end

                assert_response :unprocessable_content
                assert_equal "   ", task_title_input["value"]
                assert_includes response.body, "blank"
            end

            test "creates a task with a consistent JSON response" do
                assert_difference("LesliSupport::Items::Task.count", 1) do
                    post(
                        :create,
                        params: {
                            taskable_type: "LesliSupport::Ticket",
                            taskable_id: @ticket.id,
                            lesli_support_items_task: {
                                title: "Send a status update"
                            }
                        },
                        format: :json
                    )
                end

                assert_response :created
                assert_equal(
                    I18n.t("lesli.items.tasks.created"),
                    response.parsed_body["message"]
                )
                assert_equal "Send a status update",
                    response.parsed_body.dig("task", "title")
                assert_equal @ticket.id,
                    response.parsed_body.dig("task", "taskable_id")
                assert_equal @user.id,
                    response.parsed_body.dig("task", "creator", "id")
            end

            test "completes a task with update bang" do
                task = create_task

                patch :update, params: { id: task.id }, format: :json

                assert_response :success
                assert_predicate task.reload, :done?
                assert_equal(
                    I18n.t("lesli.items.tasks.completed"),
                    response.parsed_body["message"]
                )
                assert_equal true, response.parsed_body.dig("task", "done")
            end

            test "completes a task with a Turbo response" do
                task = create_task

                patch :update, params: { id: task.id }, format: :turbo_stream

                assert_response :success
                assert_predicate task.reload, :done?
                assert_includes response.body,
                    I18n.t("lesli.items.tasks.completed")
                assert_includes response.body,
                    ActionView::RecordIdentifier.dom_id(
                        task,
                        "lesli_support_items_task"
                    )
            end

            test "reopens a completed task" do
                task = create_task(done: true)

                patch :update, params: { id: task.id }, format: :json

                assert_response :success
                assert_not task.reload.done?
                assert_equal(
                    I18n.t("lesli.items.tasks.reopened"),
                    response.parsed_body["message"]
                )
                assert_equal false, response.parsed_body.dig("task", "done")
            end

            test "returns validation errors when a task cannot be completed" do
                task = create_task(title: "")

                patch :update, params: { id: task.id }, format: :json

                assert_response :unprocessable_content
                assert_not task.reload.done?
                assert_predicate response.parsed_body.dig("errors", "title"),
                    :present?
            end

            test "checks access through the taskable resource" do
                task = create_task
                other_account = Lesli::Account.create!(
                    status: "active",
                    name: "Other task account",
                    email: "other-tasks-#{SecureRandom.hex(4)}@example.com"
                )
                other_user = Lesli::User.new(
                    uid: "OTHER-#{SecureRandom.hex(4)}",
                    email: "other-task-user-#{SecureRandom.hex(4)}@example.com",
                    active: true,
                    account: other_account
                )
                other_user.save!(validate: false)
                @controller.define_singleton_method(:current_user) { other_user }

                assert_raises(ActiveRecord::RecordNotFound) do
                    patch :update, params: { id: task.id }, format: :json
                end

                assert_raises(ActiveRecord::RecordNotFound) do
                    post(
                        :create,
                        params: {
                            taskable_type: "LesliSupport::Ticket",
                            taskable_id: @ticket.id,
                            lesli_support_items_task: { title: "Hidden task" }
                        },
                        format: :json
                    )
                end
            end

            test "rejects a resource type that does not support tasks" do
                assert_no_difference("LesliSupport::Items::Task.count") do
                    assert_raises(ActiveRecord::RecordNotFound) do
                        post(
                            :create,
                            params: {
                                taskable_type: "Lesli::User",
                                taskable_id: @user.id,
                                lesli_support_items_task: {
                                    title: "Invalid resource task"
                                }
                            },
                            format: :json
                        )
                    end
                end
            end

            test "rejects a taskable resource that does not exist" do
                assert_no_difference("LesliSupport::Items::Task.count") do
                    assert_raises(ActiveRecord::RecordNotFound) do
                        post(
                            :create,
                            params: {
                                taskable_type: "LesliSupport::Ticket",
                                taskable_id: -1,
                                lesli_support_items_task: {
                                    title: "Missing resource task"
                                }
                            },
                            format: :json
                        )
                    end
                end
            end

            test "renders the translated empty state" do
                html = I18n.with_locale(:es) do
                    LesliView::Items::Tasks
                        .new(@ticket)
                        .render_in(@controller.view_context)
                end

                assert_includes html,
                    I18n.t("lesli.items.tasks.empty", locale: :es)
            end

            test "uses translated Turbo notifications" do
                I18n.with_locale(:es) do
                    post(
                        :create,
                        params: {
                            taskable_type: "LesliSupport::Ticket",
                            taskable_id: @ticket.id,
                            lesli_support_items_task: {
                                title: "Tarea traducida"
                            }
                        },
                        format: :turbo_stream
                    )

                    assert_response :created
                    assert_includes response.body,
                        I18n.t("lesli.items.tasks.created")
                end
            end

            test "exposes only create and update routes" do
                assert_equal "lesli_support/items/tasks", @routes.recognize_path(
                    "/items/tasks",
                    method: :post
                )[:controller]
                assert_equal "lesli_support/items/tasks", @routes.recognize_path(
                    "/items/tasks/1",
                    method: :patch
                )[:controller]

                assert_raises(ActionController::RoutingError) do
                    @routes.recognize_path("/items/tasks", method: :get)
                end
                assert_raises(ActionController::RoutingError) do
                    @routes.recognize_path("/items/tasks/1", method: :get)
                end
            end

            private

            def create_task(title: "Follow up", done: false)
                now = Time.current
                result = LesliSupport::Items::Task.insert_all!([{
                    account_id: @support_account.id,
                    user_id: @user.id,
                    taskable_type: @ticket.class.name,
                    taskable_id: @ticket.id,
                    title: title,
                    done: done,
                    created_at: now,
                    updated_at: now
                }])

                LesliSupport::Items::Task.find(result.rows.first.first)
            end

            def task_title_input
                Nokogiri::HTML
                    .fragment(response.body)
                    .at_css(
                        'input[name="lesli_support_items_task[title]"]'
                    )
            end

            def create_ticket
                now = Time.current
                result = LesliSupport::Ticket.insert_all!([{
                    account_id: @support_account.id,
                    owner_id: @user.id,
                    user_id: @user.id,
                    subject: "Task controller test",
                    uid: "TKT-#{SecureRandom.hex(4)}",
                    created_at: now,
                    updated_at: now
                }])

                LesliSupport::Ticket.find(result.rows.first.first)
            end
        end
    end
end
