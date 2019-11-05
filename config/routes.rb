Rails.application.routes.draw do
  resource :user, only: %i[edit update]

  namespace :client, path: 'c' do
    resource :org
    resources :milestone_projects do
      match :deposit, on: :member, via: %i[get post]
      get :payments, on: :member
      resources :comments, only: %i[index create]
    end
    resources :pay_methods, except: :new
    resources :projects, only: :index

    get ':type/new', to: 'pay_methods#new', constraints: { type: %w[bank_accounts cards] }
  end

  namespace :freelancer, path: 'f' do
    resource :user, only: %i[edit update]
    resources :orgs, path: :clients
    resources :milestones
    resources :milestone_projects do
      resources :comments, only: %i[index create]
      patch :activate, on: :member
      get :milestones, on: :member
      get :payments, on: :member
      get :preview, on: :member
    end
    resources :projects, only: :index
    get 'stripe/callback', to: 'stripe#callback'
    get 'stripe/connect', to: 'stripe#connect', as: :stripe_connect
  end

  resources :comments, only: %i[update]

  as :user do
    get :login, to: 'devise/sessions#new', as: :new_user_session
    post :login, to: 'devise/sessions#create', as: :user_session
    delete :logout, to: 'devise/sessions#destroy', as: :destroy_user_session
    get :logout, to: 'devise/sessions#destroy'
    get :sign_up, to: 'devise/registrations#new', as: :new_user_registration
  end
  devise_for :users,
             skip: [:sessions],
             controllers: {
               invitations: 'users/invitations',
               registrations: 'users/registrations',
             }
  namespace :users do
    post ':id/impersonate', to: 'impersonations#impersonate', as: :impersonate
    post :stop_impersonating, to: 'impersonations#stop_impersonating'
  end

  get :styleguide, to: 'application#styleguide' if Rails.env.development?

  get 'legal/terms-of-use', to: 'application#tos', as: :tos
  get 'legal/privacy-policy', to: 'application#privacy', as: :privacy
  get '(.well-known)/apple-app-site-association', to: proc { [404, {}, ['']] }

  # Redirects
  %w[signup users].each { |path| get path, to: redirect('/sign_up') }
  get 'users/password', to: redirect('/passwords/new')

  root to: 'users#home'
end
