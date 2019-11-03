CloudHelp::Engine.routes.draw do

    root to: 'dashboards#default'
    
    resources :slas
    resources :ticket_types
    resources :ticket_sources
    resources :ticket_states
    resources :ticket_priorities
    resources :ticket_categories
    resources :ticket_tags

    resources :tickets
    resources :tickets do
        get '/actions', to: 'tickets#actions'
        get '/activities', to: 'tickets#activities'
        get '/discussions', to: 'tickets#discussions'
    end
    namespace :ticket do
        resources :timelines
        resources :followers
        resources :actions
        resources :discussions
        resources :activities
        resources :files
        resources :details
    end

    scope :api do
        get '/tickets/options', to: 'tickets#api_options'
    end
    
end
