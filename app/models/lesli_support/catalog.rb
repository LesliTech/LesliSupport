module LesliSupport
    class Catalog < ApplicationRecord
        has_ancestry
        belongs_to :parent, class_name: "Catalog", optional: true

        after_save :catalog_option_order 

        def catalog_option_order 
            return if self.parent_id.nil? 
            return unless self.order.nil?
            self.order = self.id 
            self.save!
        end 
    end
end
