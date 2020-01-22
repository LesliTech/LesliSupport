CloudHelp::Engine.routes.draw do

    root to: 'dashboards#default'
    
    resources :slas
    resources :ticket_sources
    resources :ticket_priorities
    resources :ticket_types
    resources :ticket_categories
    resources :ticket_workflows
    resources :ticket_workflow_states

    resources :tickets, except: [:destroy] do
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
        scope :tickets do
            get '/options', to: 'tickets#api_options'
            get '/:id/follow_up_states', to: 'tickets#api_follow_up_states'
        end
        get '/ticket_categories/:id/tree', to: 'ticket_categories#api_tree'
    end
    
end
