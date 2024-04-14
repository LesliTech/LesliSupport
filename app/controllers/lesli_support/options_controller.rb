module LesliSupport
    class OptionsController < ApplicationController
        before_action :set_option, only: %i[ show edit update destroy ]

        # GET /options
        def index
            respond_to do |format|
                format.html { }
                format.json do

                    options = {
                        types: CatalogType.select(:id, :name),
                        categories: CatalogCategory.select(:id, :name),
                        priorities: CatalogPriority.select(:id, :name).order(:weight),
                        workspaces: CatalogWorkspace.select(:id, :name)
                    }

                    respond_with_successful(options)
                end
            end
        end
    end
end
