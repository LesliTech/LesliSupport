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

    resources :tickets, except: [:update, :destroy] do
        get '/assign', to: 'tickets#assign'
        get '/files', to: 'tickets#files'
        get '/actions', to: 'tickets#actions'
        get '/activities', to: 'tickets#activities'
        get '/discussions', to: 'tickets#discussions'
    end
    
    namespace :ticket do
        resource :timeline
        resources :followers
        resources :actions
        resources :discussions
        resources :activities
        resources :files
        resources :details
    end

    scope :api do
        scope :tickets do
            get '/assignables', to: 'tickets#api_assignables'
            get '/options', to: 'tickets#api_options'
            get '/:id/subscription_events', to: 'tickets#api_subscription_events'
            get '/:id/follow_up_states', to: 'tickets#api_follow_up_states'
            get '/:id/timelines', to: 'tickets#api_timelines'
            put '/:id/assign', to: 'tickets#api_assign'
            put '/:id/workflow', to: 'tickets#api_update_workflow'
            put '/:id/escalate', to: 'tickets#api_escalate'
            put '/:id/descalate', to: 'tickets#api_descalate'
            put '/:id/transfer', to: 'tickets#api_transfer'
            put '/:id/subscribe', to: 'tickets#api_subscribe'
            put '/:id/tags', to: 'tickets#api_tags'
        end
        get '/ticket_categories/:id/tree', to: 'ticket_categories#api_tree'
    end
    
end
