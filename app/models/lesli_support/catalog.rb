module LesliSupport
    class Catalog < Lesli::Shared::Catalog
        belongs_to :account, class_name: "LesliSupport::Account"
        has_many :items
    end
end
