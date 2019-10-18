module CloudHelp
    class ApplicationRecord < ApplicationRecord
        self.abstract_class = true
        audited
    end
end
