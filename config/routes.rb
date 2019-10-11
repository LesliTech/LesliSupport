CloudHelp::Engine.routes.draw do

    root to: 'dashboards#default'
    
    namespace :ticket do
        resources :timelines
        resources :follows
        resources :actions
        resources :comments
        resources :activities
        resources :attachments
        resources :details
    end

    resources :tickets
    resources :slas
    resources :ticket_types
    resources :ticket_sources
    resources :ticket_states
    resources :ticket_priorities
    resources :ticket_categories
    resources :ticket_tags
    

    scope :api do
    end

end
