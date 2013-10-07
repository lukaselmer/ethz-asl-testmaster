EthzAslTestmaster::Application.routes.draw do
  resources :machines

  resources :test_run_logs

  resources :test_machine_configs

  resources :test_runs

  root :to => "home#index"
  devise_for :users, controllers: {registrations: 'registrations'},
             skip: [:new, :registrations], skip_helpers: true
  resources :users
end