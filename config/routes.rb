CloudHelp::Engine.routes.draw do

    root to: 'dashboards#default'


    scope :api do
        get '/employees', to: 'employees#api_index'
    end

end
