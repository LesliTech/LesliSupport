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
        get '/files', to: 'tickets#files'
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
        scope :tickets do
            get '/options', to: 'tickets#api_options'
            get '/:id/follow_up_states', to: 'tickets#api_follow_up_states'
            get '/:id/timelines', to: 'tickets#api_timelines'
            get '/:id/assignables', to: 'tickets#api_assignables'
            post '/:id/assign', to: 'tickets#api_assign'
            put '/:id/workflow', to: 'tickets#api_update_workflow'
            put '/:id/escalate', to: 'tickets#api_escalate'
            put '/:id/descalate', to: 'tickets#api_descalate'
            put '/:id/transfer', to: 'tickets#api_transfer'
        end
        get '/ticket_categories/:id/tree', to: 'ticket_categories#api_tree'
    end
    
end
