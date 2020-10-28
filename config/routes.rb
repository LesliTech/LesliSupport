=begin

Copyright (c) 2020, all rights reserved.

All the information provided by this platform is protected by international laws related  to 
industrial property, intellectual property, copyright and relative international laws. 
All intellectual or industrial property rights of the code, texts, trade mark, design, 
pictures and any other information belongs to the owner of this platform.

Without the written permission of the owner, any replication, modification,
transmission, publication is strictly forbidden.

For more information read the license file including with this software.

// · ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~
// · 

=end
CloudHelp::Engine.routes.draw do
    root to: "dashboards#show"

    resources :custom_validations do
        scope module: :custom_validation do
            resource  :rule 
            resources :fields 
        end
        collection do
            get :options
        end
    end

    resources :workflows do
        member do
            get "actions/options",          to: "workflow/actions#options"
        end
        collection do
            post "list" => :index
            get  "associations/options",    to: "workflow/associations#options"
            get "/resources/transition-options/:cloud_object_name/:cloud_object_id", to: "workflows#transition_options"
        end
        scope module: :workflow do
            resources :associations
            resources :statuses
            resources :actions do
                collection do
                    scope :resources do
                        get :options_cloud_object_clone
                        get :options_create_cloud_object_file
                    end
                end
            end
        end
    end

    resources :dashboards do
        collection do
            post "list" => :index
            get :options
        end
        scope module: :dashboard do
            resources :components
        end
    end
  
    scope :catalog, module: :catalog do
        resources :ticket_categories do
            collection do
                post "list" => :index
            end
        end

        resources :ticket_priorities do
            collection do
                post "list" => :index
            end
        end
        
        resources :ticket_sources do
            collection do
                post "list" => :index
            end
        end
        
        resources :ticket_types do
            collection do
                post "list" => :index
            end
        end
        
    end

    resources :tickets do
        member do
            get "/resources/files-zip-download",     to: "ticket/files#zip_download"
        end
        collection do
            get "search/:text_to_search" => :search
            post "list" => :index

            get :options
            get "/files/options",                   to: "ticket/files#options"
        end
        scope module: :ticket do
            resources :actions
            resources :activities
            resources :discussions
            resources :files
            resources :subscribers
            resources :custom_fields

            resources :assignments
            resources :timelines do
                collection do
                    get :options
                end
            end
        end
    end

    resources :slas do
        scope module: :slas do
            resources :associations
        end
    end
end
