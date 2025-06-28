module LesliSupport
    class Catalog < Lesli::ApplicationLesliCatalogRecord
        belongs_to :account
        has_many :items
    end
end
