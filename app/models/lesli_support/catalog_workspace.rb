module LesliSupport
    class CatalogWorkspace < ApplicationRecord
        has_many :tickets
    end
end
