EthzAslTestmaster::Application.routes.draw do
  resources :test_run_logs

  resources :test_machine_configs

  resources :test_runs

  root :to => "home#index"
  devise_for :users, :controllers => {:registrations => "registrations"}
  resources :users
end