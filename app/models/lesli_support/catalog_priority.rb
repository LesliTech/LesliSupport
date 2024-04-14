module LesliSupport
    class CatalogPriority < ApplicationRecord
        has_many :tickets
    end
end
