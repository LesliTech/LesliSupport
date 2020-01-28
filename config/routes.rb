CloudHelp::Engine.routes.draw do

    root to: "dashboards#default"
    
    resources :slas
    resources :ticket_sources
    resources :ticket_priorities
    resources :ticket_types
    resources :ticket_categories

    resources :workflows
    resources :workflow_states, except: [:new, :show, :edit]
    
    resources :ticket_workflow_assignments, only: [:index, :update]
    

    resources :tickets, except: [:destroy] do
        scope module: :ticket do
            resources :timelines, only: [:index]   
            resources :subscribers, only: [:index, :create, :update, :destroy]
            resources :discussions
            resources :files
            resources :actions
            resources :activities
            resource :assignment, only: [:create, :show, :update]
        end
    end

    scope :options do
        get "/ticket_workflow_assignments", to: "ticket_workflow_assignments#workflow_assignment_options"
        get "/tickets", to: "tickets#ticket_options"
        get "/workflows/:cloud_object_name/:cloud_object_id", to: "workflows#workflow_options"

        scope :tickets, module: :ticket do
            get "/assignments", to: "assignments#assignment_options"
        end
    end

    scope :api do
        get "/ticket_categories/:id/tree", to: "ticket_categories#api_tree"
    end
    
end
