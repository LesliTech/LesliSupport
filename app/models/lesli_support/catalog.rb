module LesliSupport
    class Catalog < Lesli::Shared::Catalog
        belongs_to :account
        has_many :items
    end
end
