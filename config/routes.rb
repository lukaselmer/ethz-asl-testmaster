EthzAslTestmaster::Application.routes.draw do
  
  
  
  mount RailsAdmin::Engine => '/admin', :as => 'rails_admin'
  resources :scenarios
  resources :machine_configs
  resources :machines
  resources :test_run_logs

  resources :test_runs do
    member do
      get :start
      get :stop
    end
  end

  root :to => 'home#index'

  devise_for :users, controllers: {registrations: 'registrations'},
             skip: [:new, :registrations], skip_helpers: true
  resources :users
end
