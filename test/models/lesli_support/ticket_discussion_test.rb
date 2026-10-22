require "test_helper"

module LesliSupport
    class TicketDiscussionTest < ActiveSupport::TestCase
        class TicketWithCommentList < LesliSupport::Ticket
            lesli_discussions_setup(
                use: "LesliSupport::Items::Discussion",
                association_name: :comment_list
            )
        end

        setup do
            @core_account = Lesli::Account.create!(
                status: "active",
                name: "Discussion account",
                email: "discussions-#{SecureRandom.hex(4)}@example.com"
            )
            @author = Lesli::User.new(
                uid: "DSC-#{SecureRandom.hex(4)}",
                email: "discussion-user-#{SecureRandom.hex(4)}@example.com",
                active: true,
                account: @core_account
            )
            @author.save!(validate: false)
            @support_account = @core_account.support ||
                LesliSupport::Account.create!(
                    account: @core_account,
                    name: "Support"
                )
            @ticket = create_ticket
        end

        test "add_comment creates and returns the comment" do
            comment = @ticket.add_comment!(
                author: @author,
                message: "Follow up with the customer"
            )

            assert_predicate comment, :persisted?
            assert_equal @ticket, comment.discussable
            assert_equal @support_account, comment.account
            assert_equal @author, comment.author
            assert_equal "Follow up with the customer", comment.message
            assert_equal comment, @ticket.discussions.first
        end

        test "add_comment uses the configured association and class" do
            ticket = TicketWithCommentList.find(@ticket.id)
            ticket.define_singleton_method(:discussions) do
                raise "add_comment! used the default association"
            end

            comment = ticket.add_comment!(
                author: @author,
                message: "Review the latest response"
            )

            assert_equal :comment_list,
                ticket.class.lesli_discussions_association_name
            assert_equal LesliSupport::Items::Discussion,
                ticket.class.lesli_discussions_class
            assert_equal ticket, comment.discussable
            assert_includes ticket.comment_list, comment
        end

        test "add_comment raises when the comment is invalid" do
            assert_no_difference("LesliSupport::Items::Discussion.count") do
                assert_raises(ActiveRecord::RecordInvalid) do
                    @ticket.add_comment!(author: @author, message: "   ")
                end
            end
        end

        test "discussion associations isolate comments by resource" do
            other_ticket = create_ticket(subject: "Another discussion")
            @ticket.add_comment!(
                author: @author,
                message: "First ticket comment"
            )
            other_ticket.add_comment!(
                author: @author,
                message: "Second ticket comment"
            )

            assert_equal ["First ticket comment"],
                @ticket.discussions.pluck(:message)
            assert_equal ["Second ticket comment"],
                other_ticket.discussions.pluck(:message)
        end

        test "discussion associations isolate comments by tenant" do
            other_core_account = Lesli::Account.create!(
                status: "active",
                name: "Other discussion account",
                email: "other-discussions-#{SecureRandom.hex(4)}@example.com"
            )
            other_author = Lesli::User.new(
                uid: "OTHER-DSC-#{SecureRandom.hex(4)}",
                email: "other-author-#{SecureRandom.hex(4)}@example.com",
                active: true,
                account: other_core_account
            )
            other_author.save!(validate: false)
            other_support_account = other_core_account.support ||
                LesliSupport::Account.create!(
                    account: other_core_account,
                    name: "Other Support"
                )
            other_ticket = create_ticket(
                support_account: other_support_account,
                author: other_author,
                subject: "Other tenant discussion"
            )

            own_comment = @ticket.add_comment!(
                author: @author,
                message: "Current tenant comment"
            )
            other_comment = other_ticket.add_comment!(
                author: other_author,
                message: "Other tenant comment"
            )

            assert_equal @support_account, own_comment.account
            assert_equal other_support_account, other_comment.account
            assert_equal [own_comment.id], @ticket.discussions.pluck(:id)
            assert_equal [other_comment.id], other_ticket.discussions.pluck(:id)
        end

        private

        def create_ticket(
            support_account: @support_account,
            author: @author,
            subject: "Discussion API test"
        )
            now = Time.current
            result = LesliSupport::Ticket.insert_all!([{
                account_id: support_account.id,
                owner_id: author.id,
                user_id: author.id,
                subject: subject,
                uid: "TKT-#{SecureRandom.hex(4)}",
                created_at: now,
                updated_at: now
            }])

            LesliSupport::Ticket.find(result.rows.first.first)
        end
    end
end
