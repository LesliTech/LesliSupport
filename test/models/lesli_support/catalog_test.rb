require "test_helper"

module LesliSupport
    class CatalogTest < ActiveSupport::TestCase
        test "inherits from the shared catalog" do
            assert_operator LesliSupport::Catalog, :<, Lesli::Shared::Catalog
        end

        test "belongs to a support account" do
            reflection = LesliSupport::Catalog.reflect_on_association(:account)

            assert_not_nil reflection
            assert_equal :belongs_to, reflection.macro
            assert_equal LesliSupport::Account, reflection.klass
        end

        test "has many catalog items" do
            reflection = LesliSupport::Catalog.reflect_on_association(:items)

            assert_not_nil reflection
            assert_equal :has_many, reflection.macro
            assert_equal LesliSupport::Catalog::Item, reflection.klass
        end

    end
end
