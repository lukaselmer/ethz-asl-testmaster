EthzAslTestmaster::Application.routes.draw do
  resources :scenarios
  resources :machine_configs
  resources :machines
  resources :test_run_logs

  resources :test_runs do
    member do
      get :start
      get :stop
      get :download
      get :clone
      get :archive
    end
  end

  get '/logs', to: 'home#logs', as: 'logs'
  root to: 'home#index'

  devise_for :users, controllers: {registrations: 'registrations'},
             skip: [:new, :registrations], skip_helpers: true
  resources :users
end
