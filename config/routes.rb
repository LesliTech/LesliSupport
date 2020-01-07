CloudHelp::Engine.routes.draw do

    root to: 'dashboards#default'
    
    resources :slas
    resources :ticket_types
    resources :ticket_sources
    resources :ticket_states
    resources :ticket_priorities
    resources :ticket_categories
    resources :ticket_tags
    resources :ticket_workflows, except: [:new, :create, :destroy]

    resources :tickets, except: [:destroy] do
        get '/activities', to: 'tickets#activities'
        
        scope module: :ticket do
            resources :timelines, only: [:index]   
            resources :subscribers, only: [:index, :create, :update, :destroy]
            resources :assignments, only: [:index]
            resources :discussions
            resources :files
            resources :actions
        end
    end
    
    namespace :ticket do
        resources :activities
    end

    scope :api do
        scope :tickets do
            get '/options', to: 'tickets#api_options'
            get '/:id/follow_up_states', to: 'tickets#api_follow_up_states'
        end
        get '/ticket_categories/:id/tree', to: 'ticket_categories#api_tree'
    end
    
end
