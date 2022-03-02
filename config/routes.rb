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

    scope module: :account do
        resources :settings, only: [:index, :create, :destroy] do
            collection do
                get :options
            end
        end
    end

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
            get "actions/options",                                                  to: "workflow/actions#options"
            get "/checks/options",                                                  to: "workflow/checks#options"
        end
        collection do
            get  "associations/options",                                            to: "workflow/associations#options"
            get "/resources/transition-options/:cloud_object_name/:cloud_object_id",to: "workflows#transition_options"
        end
        scope module: :workflow do
            resources :associations
            resources :checks
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

        resources :ticket_workspaces
    end

    resources :tickets do
        member do
            scope :resources do
                get :images
                get "/files-zip-download",      to: "ticket/files#zip_download"
            end
        end
        collection do
            get "search/:text_to_search" => :search

            get :options
            get "/files/options",               to: "ticket/files#options"
            get "/assignments/options",         to: "ticket/assignments#options"
        end
        scope module: :ticket do
            resources :actions
            resources :activities
            resources :discussions
            resources :files
            resources :subscribers
            resources :custom_fields

            resources :assignments
            resources :histories
            resources :timelines do
                collection do
                    get :options
                end
            end
        end
    end

    resources :slas do
        collection do
            get "search/:text_to_search" => :search
            post "list" => :index

            get :options
            get "/files/options",               to: "sla/files#options"
            get "/associations/options",        to: "sla/associations#options"
        end
        scope module: :sla do
            resources :actions
            resources :activities
            resources :discussions
            resources :files
            resources :subscribers
            resources :custom_fields
            
            resources :associations
        end
    end

    resources :reports, only: :index do
        collection do
            get :tickets_general
        end
    end
end
