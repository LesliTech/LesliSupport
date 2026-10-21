require "test_helper"

module LesliSupport
    class TicketActivityTest < ActiveSupport::TestCase
        setup do
            @core_account = Lesli::Account.create!(
                status: "active",
                name: "Activity account",
                email: "activities-#{SecureRandom.hex(4)}@example.com"
            )
            @requester = create_user("requester")
            @current_user = create_user("agent")
            @support_account = @core_account.support ||
                LesliSupport::Account.create!(
                    account: @core_account,
                    name: "Support"
                )
            @ticket = create_ticket
        end

        test "records an activity through the ticket association" do
            activity = @ticket.record_activity!(
                actor: @current_user,
                code: :priority_changed,
                description: "Ticket priority changed",
                metadata: { from: 1, to: 2 }
            )

            assert_predicate activity, :persisted?
            assert_equal @ticket, activity.subject
            assert_equal @current_user, activity.actor
            assert_equal @support_account, activity.account
            assert_equal "priority_changed", activity.activity_code
            assert_equal "activity", activity.activity_type
            assert_equal({ "from" => 1, "to" => 2 }, activity.metadata)
        end

        test "raises when an activity violates its contract" do
            assert_raises(ActiveRecord::RecordInvalid) do
                @ticket.record_activity!(actor: nil, code: :priority_changed)
            end

            assert_raises(ActiveRecord::RecordInvalid) do
                @ticket.record_activity!(actor: @current_user, code: "Priority changed")
            end

            assert_raises(ActiveRecord::RecordInvalid) do
                @ticket.record_activity!(
                    actor: @current_user,
                    code: :priority_changed,
                    metadata: []
                )
            end
        end

        test "validates every required activity relationship and value" do
            activity = LesliSupport::Items::Activity.new(
                activity_code: "Priority changed",
                metadata: []
            )

            refute_predicate activity, :valid?
            assert_predicate activity.errors[:actor], :any?
            assert_predicate activity.errors[:account], :any?
            assert_predicate activity.errors[:subject], :any?
            assert_predicate activity.errors[:activity_code], :any?
            assert_predicate activity.errors[:metadata], :any?
        end

        test "records ticket creation with the current user as actor" do
            service = TicketService.new(@current_user).create(
                subject: "New support request"
            )

            assert_predicate service, :successful?

            ticket = service.result
            activity = ticket.activities.first

            assert_equal "ticket_created", activity.activity_code
            assert_equal @current_user, activity.actor
            assert_nil activity.metadata["from"]
            assert_equal ticket.id, activity.metadata.dig("to", "id")
            assert_equal ticket.uid, activity.metadata.dig("to", "uid")
            assert_equal ticket.subject, activity.metadata.dig("to", "subject")
        end

        test "records relation changes with from and to snapshots" do
            new_owner = create_user("new owner")
            service = ticket_service

            assert_difference("LesliSupport::Items::Activity.count", 1) do
                service.update(owner_id: new_owner.id)
            end

            assert_predicate service, :successful?

            activity = @ticket.activities.first
            assert_equal "owner_changed", activity.activity_code
            assert_equal @current_user, activity.actor
            assert_equal @support_account, activity.account
            assert_equal @requester.id, activity.metadata.dig("from", "id")
            assert_equal @requester.name, activity.metadata.dig("from", "name")
            assert_equal new_owner.id, activity.metadata.dig("to", "id")
            assert_equal new_owner.name, activity.metadata.dig("to", "name")
        end

        test "records a nil snapshot when an optional relation is removed" do
            catalog = @support_account.catalogs.create!(name: "Priorities")
            priority = catalog.items.create!(name: "High")
            @ticket.update!(priority: priority)

            service = ticket_service
            service.update(priority_id: nil)

            assert_predicate service, :successful?

            activity = @ticket.activities.first
            assert_equal "priority_changed", activity.activity_code
            assert_equal priority.id, activity.metadata.dig("from", "id")
            assert_equal priority.name, activity.metadata.dig("from", "name")
            assert_nil activity.metadata["to"]
            assert_equal "Ticket priority removed", activity.description
        end

        test "rolls back the ticket update when activity creation fails" do
            new_owner = create_user("rollback owner")
            service = ticket_service
            invalid_activity = LesliSupport::Items::Activity.new
            invalid_activity.valid?

            ticket = service.result
            original_record_activity = ticket.method(:record_activity!)
            create_activity = lambda do |**|
                raise ActiveRecord::RecordInvalid.new(invalid_activity)
            end
            ticket.define_singleton_method(:record_activity!, create_activity)

            assert_no_difference("LesliSupport::Items::Activity.count") do
                service.update(owner_id: new_owner.id)
            end

            refute_predicate service, :successful?
            assert_equal @requester, service.result.owner
            assert_equal @requester, @ticket.reload.owner
        ensure
            ticket&.define_singleton_method(
                :record_activity!,
                original_record_activity
            )
        end

        private

        def create_user(label)
            user = Lesli::User.new(
                uid: "ACT-#{SecureRandom.hex(4)}",
                email: "activity-user-#{SecureRandom.hex(4)}@example.com",
                first_name: label.titleize,
                active: true,
                account: @core_account
            )
            user.save!(validate: false)
            user
        end

        def ticket_service
            TicketService.new(@current_user).find(id: @ticket.id)
        end

        def create_ticket
            now = Time.current
            result = LesliSupport::Ticket.insert_all!([{
                account_id: @support_account.id,
                owner_id: @requester.id,
                user_id: @requester.id,
                subject: "Activity API test",
                uid: "TKT-#{SecureRandom.hex(4)}",
                created_at: now,
                updated_at: now
            }])

            LesliSupport::Ticket.find(result.rows.first.first)
        end
    end
end
