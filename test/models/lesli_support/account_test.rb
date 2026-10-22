require "test_helper"

module LesliSupport
    class AccountTest < LesliTesting::ModelTester
        test "belongs to a Lesli account" do
            reflection = LesliSupport::Account.reflect_on_association(:account)

            assert_not_nil reflection
            assert_equal :belongs_to, reflection.macro
            assert_equal "Lesli::Account", reflection.class_name
            assert_equal :support, reflection.options[:inverse_of]
        end

        test "allows only one support account per Lesli account" do
            core_account = Lesli::Account.create!(
                status: "active",
                name: "Unique support account",
                email: "support-account-#{SecureRandom.hex(4)}@example.com"
            )
            existing_account = core_account.support ||
                LesliSupport::Account.create!(account: core_account)
            duplicate_account = LesliSupport::Account.new(account: core_account)

            assert_predicate existing_account, :persisted?
            refute_predicate duplicate_account, :valid?
            assert_predicate duplicate_account.errors[:account_id], :any?
        end

        test "has many support resources" do
            dashboards = LesliSupport::Account.reflect_on_association(:dashboards)
            catalogs = LesliSupport::Account.reflect_on_association(:catalogs)
            tickets = LesliSupport::Account.reflect_on_association(:tickets)

            assert_equal :has_many, dashboards&.macro
            assert_equal LesliSupport::Dashboard, dashboards&.klass
            assert_equal :has_many, catalogs&.macro
            assert_equal LesliSupport::Catalog, catalogs&.klass
            assert_equal :has_many, tickets&.macro
            assert_equal LesliSupport::Ticket, tickets&.klass
        end

        test "initializes account records after creation" do
            callback = LesliSupport::Account
                ._create_callbacks
                .find { |registered_callback| registered_callback.filter == :initialize_account }

            assert_not_nil callback
            assert_equal :after, callback.kind
        end
    end
end
