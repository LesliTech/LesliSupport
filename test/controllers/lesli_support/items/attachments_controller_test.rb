require "test_helper"

module LesliSupport
    module Items
        class AttachmentsControllerTest < ActionController::TestCase
            tests LesliSupport::Items::AttachmentsController

            setup do
                @routes = LesliSupport::Engine.routes
                @account = Lesli::Account.create!(
                    status: "active",
                    name: "Attachment account",
                    email: "attachments-#{SecureRandom.hex(4)}@example.com"
                )
                @user = Lesli::User.new(
                    uid: "ATT-#{SecureRandom.hex(4)}",
                    email: "attachments-user-#{SecureRandom.hex(4)}@example.com",
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

            test "uploads an account-scoped attachment" do
                assert_difference("LesliSupport::Items::Attachment.count", 1) do
                    post(
                        :create,
                        params: {
                            attachable_type: "LesliSupport::Ticket",
                            attachable_id: @ticket.id,
                            lesli_support_items_attachment: {
                                label: "Test document",
                                file: uploaded_file
                            }
                        },
                        format: :json
                    )
                end

                assert_response :success

                attachment = LesliSupport::Items::Attachment.last
                assert_equal @support_account, attachment.account
                assert_equal @user, attachment.user
                assert_equal @ticket, attachment.attachable
                assert_equal "attachment.txt", attachment.file.filename.to_s
                assert_equal "Test document", response.parsed_body["label"]
            end

            test "rejects attachable types that do not opt in" do
                assert_raises(ActiveRecord::RecordNotFound) do
                    post(
                        :create,
                        params: {
                            attachable_type: "Lesli::User",
                            attachable_id: @user.id,
                            lesli_support_items_attachment: {
                                file: uploaded_file
                            }
                        },
                        format: :json
                    )
                end
            end

            test "removes an attachment through its account-scoped route" do
                attachment = create_attachment

                assert_difference("LesliSupport::Items::Attachment.count", -1) do
                    delete :destroy, params: { id: attachment.id }, format: :json
                end

                assert_response :success
                assert_equal(
                    I18n.t("lesli.items.attachments.deleted"),
                    response.parsed_body["message"]
                )
            end

            test "lists only the requested attachable files" do
                attachment = create_attachment

                get(
                    :index,
                    params: {
                        attachable_type: "LesliSupport::Ticket",
                        attachable_id: @ticket.id
                    },
                    format: :json
                )

                assert_response :success
                assert_equal [attachment.id], response.parsed_body.pluck("id")
                assert_equal "attachment.txt",
                    response.parsed_body.first["filename"]
            end

            test "redirects downloads through a short-lived service URL" do
                attachment = create_attachment

                get :show, params: { id: attachment.id }

                assert_response :redirect
                assert_match(/active_storage/, response.location)
            end

            test "does not expose another account attachment" do
                attachment = create_attachment
                other_account = Lesli::Account.create!(
                    status: "active",
                    name: "Other attachment account",
                    email: "other-attachments-#{SecureRandom.hex(4)}@example.com"
                )
                other_user = Lesli::User.new(
                    uid: "OTHER-#{SecureRandom.hex(4)}",
                    email: "other-attachments-user-#{SecureRandom.hex(4)}@example.com",
                    active: true,
                    account: other_account
                )
                other_user.save!(validate: false)
                @controller.define_singleton_method(:current_user) { other_user }

                assert_raises(ActiveRecord::RecordNotFound) do
                    get :show, params: { id: attachment.id }
                end
            end

            private

            def uploaded_file
                Rack::Test::UploadedFile.new(
                    File.expand_path(
                        "../../../fixtures/files/attachment.txt",
                        __dir__
                    ),
                    "text/plain"
                )
            end

            def create_attachment
                @ticket.attachments.create!(
                    account: @support_account,
                    user: @user,
                    label: "Existing attachment",
                    file: uploaded_file
                )
            end

            def create_ticket
                now = Time.current
                result = LesliSupport::Ticket.insert_all!([{
                    account_id: @support_account.id,
                    owner_id: @user.id,
                    user_id: @user.id,
                    subject: "Attachment controller test",
                    uid: "TKT-#{SecureRandom.hex(4)}",
                    created_at: now,
                    updated_at: now
                }])

                LesliSupport::Ticket.find(result.rows.first.first)
            end
        end
    end
end
