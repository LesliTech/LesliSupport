CloudHelp::Engine.routes.draw do

    root to: "dashboards#default"

    scope :catalog, module: :catalog do
        resources :ticket_categories
        resources :ticket_priorities
        resources :ticket_types
    end

    resources :workflows do
        scope module: :workflow do
            resources :associations
        end
    end

    resources :tickets, except: [:destroy] do
        scope module: :ticket do
            resource :assignment, only: [:create, :show, :update]
            resources :timelines, only: [:index]

            resources :actions
            resources :activities
            resources :discussions
            resources :files
            resources :subscribers, only: [:index, :create, :update, :destroy]
            resources :custom_fields
            resources :custom_field_values
        end
    end

    resources :slas do
        scope module: :sla do
            resources :associations
        end
    end

    scope :options do
        scope module: :workflow do
            get "/workflows/associations", to: "associations#association_options"
        end

        scope :tickets, module: :ticket do
            get "/assignments", to: "assignments#assignment_options"
        end

        get "/workflows/:cloud_object_name/:cloud_object_id", to: "workflows#workflow_options"  # Options to transition from one state to another one
        get "/tickets", to: "tickets#ticket_options"
    end

end
