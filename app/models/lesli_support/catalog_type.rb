module LesliSupport
    class CatalogType < ApplicationRecord
        has_many :tickets
    end
end
