Rails.application.routes.draw do
  resource :user, only: %i[edit update]

  namespace :client, path: 'c' do
    resource :org
    resources :milestone_projects do
      get :payments, on: :member
    end
    resources :projects, only: :index
  end

  namespace :freelancer, path: 'f' do
    resources :orgs, path: :clients
    resources :milestones
    resources :milestone_projects do
      patch :activate, on: :member
      get :milestones, on: :member
      get :payments, on: :member
      get :preview, on: :member
    end
    resources :projects, only: :index
    get 'stripe/callback', to: 'stripe#callback'
    get 'stripe/connect', to: 'stripe#connect', as: :stripe_connect
  end

  as :user do
    get :login, to: 'devise/sessions#new', as: :new_user_session
    post :login, to: 'devise/sessions#create', as: :user_session
    delete :logout, to: 'devise/sessions#destroy', as: :destroy_user_session
    get :logout, to: 'devise/sessions#destroy'
    get :sign_up, to: 'devise/registrations#new', as: :new_user_registration
  end
  devise_for :users, skip: [:sessions], controllers: { registrations: 'users/registrations' }
  namespace :users do
    get ':id/impersonate', to: 'impersonations#impersonate'
    get 'stop_impersonating', to: 'impersonations#stop_impersonating'
  end

  get 'styleguide', to: 'application#styleguide'

  get 'legal/terms-of-use', to: 'application#tos', as: :tos
  get 'legal/privacy-policy', to: 'application#privacy', as: :privacy
  get '(.well-known)/apple-app-site-association', to: proc { [404, {}, ['']] }

  # Redirects
  %w[signup users].each { |path| get path, to: redirect('/sign_up') }
  get 'users/password', to: redirect('/passwords/new')

  root to: redirect('/f/projects')
end
