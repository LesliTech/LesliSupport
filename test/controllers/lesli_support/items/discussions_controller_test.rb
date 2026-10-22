require "test_helper"

module LesliSupport
    module Items
        class DiscussionsControllerTest < ActionController::TestCase
            tests LesliSupport::Items::DiscussionsController

            setup do
                @routes = LesliSupport::Engine.routes
                @account = Lesli::Account.create!(
                    status: "active",
                    name: "Discussion account",
                    email: "discussions-#{SecureRandom.hex(4)}@example.com"
                )
                @user = Lesli::User.new(
                    uid: "DSC-#{SecureRandom.hex(4)}",
                    email: "discussion-user-#{SecureRandom.hex(4)}@example.com",
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

            test "creates an account-scoped comment with Turbo" do
                assert_difference("LesliSupport::Items::Discussion.count", 1) do
                    post :create,
                        params: comment_params("Follow up with the customer"),
                        format: :turbo_stream
                end

                assert_response :created
                assert_includes response.body,
                    I18n.t("lesli.items.discussions.created")
                assert_includes response.body, "Follow up with the customer"
                assert_match(
                    /<turbo-stream action="replace" target="discussions_ticket_#{@ticket.id}">/,
                    response.body
                )
                assert_match(
                    /<textarea[^>]*>\s*<\/textarea>/,
                    response.body
                )

                comment = LesliSupport::Items::Discussion.last
                assert_equal @support_account, comment.account
                assert_equal @user, comment.author
                assert_equal @ticket, comment.discussable
            end

            test "creates a comment with a consistent JSON response" do
                assert_difference("LesliSupport::Items::Discussion.count", 1) do
                    post :create,
                        params: comment_params("Send a status update"),
                        format: :json
                end

                assert_response :created
                assert_equal(
                    I18n.t("lesli.items.discussions.created"),
                    response.parsed_body["message"]
                )
                assert_equal "Send a status update",
                    response.parsed_body.dig("comment", "message")
                assert_equal @ticket.id,
                    response.parsed_body.dig("comment", "discussable_id")
                assert_equal @user.id,
                    response.parsed_body.dig("comment", "author", "id")
            end

            test "renders submitted HTML as escaped plain text" do
                content = "<script>alert('unsafe')</script>"

                post :create,
                    params: comment_params(content),
                    format: :turbo_stream

                assert_response :created
                assert_includes response.body,
                    "&lt;script&gt;alert(&#39;unsafe&#39;)&lt;/script&gt;"
                refute_includes response.body, content
                assert_equal content,
                    LesliSupport::Items::Discussion.last.message
            end

            test "returns 422 for an invalid comment" do
                assert_no_difference("LesliSupport::Items::Discussion.count") do
                    post :create,
                        params: comment_params("   "),
                        format: :json
                end

                assert_response :unprocessable_content
                assert_equal(
                    I18n.t("lesli.items.discussions.invalid"),
                    response.parsed_body["message"]
                )
                assert_predicate response.parsed_body.dig("errors", "message"),
                    :present?
            end

            test "returns translated Turbo validation errors" do
                I18n.with_locale(:es) do
                    assert_no_difference(
                        "LesliSupport::Items::Discussion.count"
                    ) do
                        post :create,
                            params: comment_params("   "),
                            format: :turbo_stream
                    end

                    assert_response :unprocessable_content
                    assert_includes response.body,
                        I18n.t("lesli.items.discussions.invalid")
                    assert_match(
                        /<textarea[^>]*>\s+<\/textarea>/,
                        response.body
                    )
                    assert_includes response.body, "Message"
                    assert_includes response.body,
                        I18n.t("lesli.items.discussions.add")
                    assert_includes response.body,
                        I18n.t("lesli.items.discussions.empty")
                end
            end

            test "checks access through the discussable resource" do
                other_account = Lesli::Account.create!(
                    status: "active",
                    name: "Other discussion account",
                    email: "other-discussions-#{SecureRandom.hex(4)}@example.com"
                )
                other_user = Lesli::User.new(
                    uid: "OTHER-#{SecureRandom.hex(4)}",
                    email: "other-discussion-#{SecureRandom.hex(4)}@example.com",
                    active: true,
                    account: other_account
                )
                other_user.save!(validate: false)
                @controller.define_singleton_method(:current_user) { other_user }

                assert_no_difference("LesliSupport::Items::Discussion.count") do
                    assert_raises(ActiveRecord::RecordNotFound) do
                        post :create,
                            params: comment_params("Hidden comment"),
                            format: :json
                    end
                end
            end

            test "rejects an unsupported discussable type" do
                assert_no_difference("LesliSupport::Items::Discussion.count") do
                    assert_raises(ActiveRecord::RecordNotFound) do
                        post :create,
                            params: comment_params(
                                "Invalid resource comment",
                                discussable_type: "Lesli::User",
                                discussable_id: @user.id
                            ),
                            format: :json
                    end
                end
            end

            test "requires an existing discussable resource" do
                assert_no_difference("LesliSupport::Items::Discussion.count") do
                    assert_raises(ActiveRecord::RecordNotFound) do
                        post :create,
                            params: comment_params(
                                "Missing resource comment",
                                discussable_id: -1
                            ),
                            format: :json
                    end
                end
            end

            test "uses the translated success notification" do
                I18n.with_locale(:es) do
                    post :create,
                        params: comment_params("Comentario traducido"),
                        format: :turbo_stream

                    assert_response :created
                    assert_includes response.body,
                        I18n.t("lesli.items.discussions.created")
                end
            end

            test "exposes only the create route" do
                route = @routes.recognize_path(
                    "/items/discussions",
                    method: :post
                )

                assert_equal "lesli_support/items/discussions",
                    route[:controller]

                assert_raises(ActionController::RoutingError) do
                    @routes.recognize_path(
                        "/items/discussions",
                        method: :get
                    )
                end
                assert_raises(ActionController::RoutingError) do
                    @routes.recognize_path(
                        "/items/discussions/1",
                        method: :patch
                    )
                end
            end

            private

            def comment_params(message, discussable_type: nil, discussable_id: nil)
                {
                    discussable_type: discussable_type || "LesliSupport::Ticket",
                    discussable_id: discussable_id || @ticket.id,
                    lesli_support_items_discussion: {
                        message: message
                    }
                }
            end

            def create_ticket
                now = Time.current
                result = LesliSupport::Ticket.insert_all!([{
                    account_id: @support_account.id,
                    owner_id: @user.id,
                    user_id: @user.id,
                    subject: "Discussion controller test",
                    uid: "TKT-#{SecureRandom.hex(4)}",
                    created_at: now,
                    updated_at: now
                }])

                LesliSupport::Ticket.find(result.rows.first.first)
            end
        end
    end
end
