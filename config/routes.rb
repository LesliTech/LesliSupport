CloudHelp::Engine.routes.draw do

  namespace :ticket do
    resources :followers
  end
  namespace :ticket do
    resources :files
  end
    root to: 'dashboards#default'
    
    namespace :ticket do
        resources :timelines
        resources :follows
        resources :actions
        resources :discussions
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

    resources :tickets do
        get '/discussions', to: 'tickets#discussions'
        get '/actions', to: 'tickets#actions'
        get '/activities', to: 'tickets#activities'
    end
    
end
