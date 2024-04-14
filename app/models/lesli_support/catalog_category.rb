module LesliSupport
    class CatalogCategory < ApplicationRecord
        has_many :tickets
    end
end
