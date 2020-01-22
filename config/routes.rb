CloudHelp::Engine.routes.draw do

    root to: "dashboards#default"
    
    resources :slas
    resources :ticket_sources
    resources :ticket_priorities
    resources :ticket_types
    resources :ticket_categories
    resources :ticket_workflow_states
    resources :ticket_workflows do
        get "/options", to: "ticket_workflows#workflow_options"
    end

    scope :tickets do 
        get "/options", to: "tickets#ticket_options"
    end

    resources :tickets, except: [:destroy] do
        get "/workflow_options", to: "tickets#workflow_options"

        scope module: :ticket do
            resource :assignment, only: [:create, :show, :update] do
                get "/options", to: "assignments#assignment_options"
            end
            resources :timelines, only: [:index]   
            resources :subscribers, only: [:index, :create, :update, :destroy]
            resources :discussions
            resources :files
            resources :actions
            resources :activities
        end
    end

    scope :api do
        get "/ticket_categories/:id/tree", to: "ticket_categories#api_tree"
    end
    
end
