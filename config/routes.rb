CloudHelp::Engine.routes.draw do

  namespace :ticket do
    resources :timelines
  end
  namespace :ticket do
    resources :follows
  end
  namespace :ticket do
    resources :actions
  end
  namespace :ticket do
    resources :comments
  end
  namespace :ticket do
    resources :activities
  end
  namespace :ticket do
    resources :attachments
  end
  namespace :ticket do
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
    root to: 'dashboards#default'


    scope :api do
        get '/employees', to: 'employees#api_index'
    end

end
