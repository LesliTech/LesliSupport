CloudHelp::Engine.routes.draw do

  namespace :ticket do
    resources :custom_fields
  end
  namespace :sla do
    resources :associations
  end
  namespace :workflow do
    resources :associations
  end
  namespace :workflow do
    resources :statuses
  end
  resources :workflows
  resources :catalogs
  namespace :catalog do
    resources :ticket_categories
  end
  namespace :catalog do
    resources :ticket_sources
  end
  namespace :catalog do
    resources :ticket_priorities
  end
  namespace :catalog do
    resources :ticket_types
  end
    root to: "dashboards#default"
    
    resources :ticket_sources
    resources :ticket_priorities
    resources :ticket_types
    resources :ticket_categories

    resources :slas

      resources :workflow_states, except: [:new, :show, :edit]
    resources :ticket_workflows, only: [:index, :update]
    

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
        get "/tickets", to: "tickets#ticket_options"
        get "/ticket_workflows", to: "ticket_workflows#workflow_options"
        get "/workflows/:cloud_object_name/:cloud_object_id", to: "workflows#workflow_options"

        scope :tickets, module: :ticket do
            get "/assignments", to: "assignments#assignment_options"
        end
    end

end
