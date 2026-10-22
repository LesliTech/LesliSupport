require "test_helper"

module LesliSupport
    class TicketActivityTest < ActiveSupport::TestCase
        class TicketWithActivityHistory < LesliSupport::Ticket
            lesli_activities_setup(
                use: "LesliSupport::Items::Activity",
                association_name: :activity_history
            )
        end

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
            assert_equal @core_account, activity.account.account
            assert_equal "priority_changed", activity.activity_code
            assert_equal "activity", activity.activity_type
            assert_equal({ "from" => 1, "to" => 2 }, activity.metadata)
        end

        test "records through the configured activity association" do
            ticket = TicketWithActivityHistory.find(@ticket.id)
            ticket.define_singleton_method(:activities) do
                raise "record_activity! used the default association"
            end

            activity = ticket.record_activity!(
                actor: @current_user,
                code: :ticket_created
            )

            assert_equal :activity_history,
                ticket.class.lesli_activities_association_name
            assert_equal ticket, activity.subject
            assert_includes ticket.activity_history, activity
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

        test "records the current actor when they differ from the ticket creator" do
            new_owner = create_user("assigned owner")

            ticket_service.update(owner_id: new_owner.id)

            activity = @ticket.activities.first
            assert_equal @requester, @ticket.user
            assert_equal @current_user, activity.actor
            refute_equal @ticket.user, activity.actor
        end

        test "records a nil snapshot when an optional relation is removed" do
            catalog = @support_account.catalogs.create!(name: "Priorities")
            old_priority = catalog.items.create!(name: "Medium")
            new_priority = catalog.items.create!(name: "High")
            @ticket.update!(priority: old_priority)

            service = ticket_service
            service.update(priority_id: new_priority.id)

            changed = @ticket.activities.first
            assert_equal old_priority.id, changed.metadata.dig("from", "id")
            assert_equal old_priority.name, changed.metadata.dig("from", "name")
            assert_equal new_priority.id, changed.metadata.dig("to", "id")
            assert_equal new_priority.name, changed.metadata.dig("to", "name")

            service.update(priority_id: nil)

            assert_predicate service, :successful?

            removed = @ticket.activities.first
            assert_equal "priority_changed", removed.activity_code
            assert_equal new_priority.id, removed.metadata.dig("from", "id")
            assert_equal new_priority.name, removed.metadata.dig("from", "name")
            assert_nil removed.metadata["to"]
            assert_equal "Ticket priority removed", removed.description
        end

        test "does not expose a ticket or its activities to another tenant" do
            other_account = create_core_account("isolated")
            other_user = create_user("other tenant", account: other_account)
            other_support_account = other_account.support ||
                LesliSupport::Account.create!(
                    account: other_account,
                    name: "Other support"
                )

            @ticket.record_activity!(
                actor: @current_user,
                code: :ticket_created
            )

            service = TicketService.new(other_user).find(id: @ticket.id)

            refute_predicate service, :found?
            assert_empty other_support_account.tickets
            assert_empty LesliSupport::Items::Activity.where(
                account: other_support_account
            )
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

        test "presents translated activity data for the shared timeline" do
            activity = @ticket.record_activity!(
                actor: @current_user,
                code: :owner_changed,
                description: "Stored fallback description",
                metadata: {
                    from: { id: @requester.id, name: @requester.name },
                    to: { id: @current_user.id, name: @current_user.name }
                }
            )

            component = I18n.with_locale(:es) do
                LesliView::Items::Activities.new(
                    @ticket,
                    i18n_scope: "lesli_support.items.activities",
                    icons: { owner_changed: "manage_accounts" }
                )
            end
            presented = component.activities.find do |item|
                item["icon"] == activity.activity_code
            end

            assert_equal "Responsable actualizado", presented["operation"]
            assert_equal(
                "Se cambió de Requester a Agent.",
                presented["description"]
            )
            assert_equal @current_user.full_name, presented["actor"]
            assert_equal "owner_changed", presented["icon"]
            assert_equal "manage_accounts", component.icons[:owner_changed]

            html = component.render_in(ActionView::Base.empty)
            assert_includes html, "Responsable actualizado"
            assert_includes html, "Se cambió de Requester a Agent."
            assert_includes html, "manage_accounts"
        end

        test "uses the shared translated empty state" do
            text = I18n.with_locale(:es) do
                LesliView::Items::Activities.new(
                    @ticket,
                    i18n_scope: "lesli_support.items.activities"
                ).empty_text
            end

            assert_equal "Todavía no se ha registrado actividad.", text
        end

        test "orders activities from newest to oldest" do
            older = create_activity(:older_event, 3.days.ago)
            newest = create_activity(:newest_event, 1.hour.ago)
            middle = create_activity(:middle_event, 1.day.ago)

            assert_equal(
                [newest.id, middle.id, older.id],
                @ticket.activities.reload.pluck(:id)
            )
        end

        test "uses the record id when activities share a timestamp" do
            timestamp = Time.current.change(usec: 0)
            first = create_activity(:first_event, timestamp)
            second = create_activity(:second_event, timestamp)

            assert_equal(
                [second.id, first.id],
                @ticket.activities.reload.pluck(:id)
            )
        end

        test "limits the initial timeline collection" do
            30.times do |index|
                create_activity("event_#{index}", index.minutes.ago)
            end

            component = LesliView::Items::Activities.new(@ticket)

            assert_equal 25, component.activities.length
            assert_equal "event_0", component.activities.first["icon"]
            assert_equal "event_24", component.activities.last["icon"]
        end

        private

        def create_activity(code, created_at)
            activity = @ticket.record_activity!(
                actor: @current_user,
                code: code,
                description: code.to_s.humanize
            )
            activity.update_column(:created_at, created_at)
            activity
        end

        def create_core_account(label)
            Lesli::Account.create!(
                status: "active",
                name: "#{label.titleize} account",
                email: "#{label.parameterize}-#{SecureRandom.hex(4)}@example.com"
            )
        end

        def create_user(label, account: @core_account)
            user = Lesli::User.new(
                uid: "ACT-#{SecureRandom.hex(4)}",
                email: "activity-user-#{SecureRandom.hex(4)}@example.com",
                first_name: label.titleize,
                active: true,
                account: account
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
