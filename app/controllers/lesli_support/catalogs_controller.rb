module LesliSupport
    class CatalogsController < ApplicationController
        def options 
            respond_to do |format|
                format.html { }
                format.json do
                    respond_with_successful(CatalogService.new(current_user, query).options)
                end
            end
        end
    end
end
