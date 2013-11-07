EthzAslTestmaster::Application.routes.draw do
  resources :scenarios
  resources :machine_configs
  resources :machines
  resources :test_run_logs

  resources :test_runs do
    member do
      get :analyze
      post :analyze
      get :download
      get :clone
      get :archive
    end
  end

  get '/build_log_analyzer', to: 'home#build_log_analyzer', as: 'build_log_analyzer'
  get '/logs', to: 'home#logs', as: 'logs'
  root to: 'home#index'

  devise_for :users, controllers: {registrations: 'registrations'},
             skip: [:new, :registrations], skip_helpers: true
  resources :users
end
