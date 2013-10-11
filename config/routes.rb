EthzAslTestmaster::Application.routes.draw do
  resources :machine_configs
  resources :machines
  resources :test_run_logs
  resources :test_runs
  root :to => "home#index"
  devise_for :users, controllers: {registrations: 'registrations'},
             skip: [:new, :registrations], skip_helpers: true
  resources :users
end