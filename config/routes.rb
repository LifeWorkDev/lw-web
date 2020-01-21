Rails.application.routes.draw do
  resource :user, only: %i[edit update]

  namespace :client, path: 'c' do
    resource :org
    resources :milestone_projects do
      match :deposit, on: :member, via: %i[get post]
      get :payments, on: :member
      resources :comments, only: %i[index create]
    end
    resources :pay_methods, except: :new do
      get :created, on: :collection
    end
    resources :projects, only: :index

    get ':type/new', to: 'pay_methods#new', constraints: { type: %w[bank_accounts cards] }
  end

  namespace :freelancer, path: 'f' do
    resource :user, only: %i[edit update] do
      get :waitlist, on: :member
    end
    resources :orgs, path: :clients
    resources :milestones
    resources :milestone_projects do
      resources :comments, only: %i[index create]
      patch :activate, on: :member
      get :milestones, on: :member
      get :payments, on: :member
      get :preview, on: :member
    end
    resources :projects, only: :index do
      match :status, on: :member, via: %i[get patch]
    end
    scope controller: :content, as: :content, path: :content do
      get :walkthrough
    end
    scope controller: :stripe, as: :stripe, path: :stripe do
      get :callback
      get :connect
      get :dashboard
    end
  end

  resources :comments, only: %i[update]

  as :user do
    get :login, to: 'users/sessions#new', as: :new_user_session
    post :login, to: 'users/sessions#create', as: :user_session
    delete :logout, to: 'users/sessions#destroy', as: :destroy_user_session
    get :logout, to: 'users/sessions#destroy'
    get :sign_up, to: 'users/registrations#new', as: :new_user_registration
  end
  devise_for :users,
             skip: [:sessions],
             controllers: {
               invitations: 'users/invitations',
               registrations: 'users/registrations',
               sessions: 'users/sessions',
             }
  namespace :users do
    post ':id/impersonate', to: 'impersonations#impersonate', as: :impersonate
    post :stop_impersonating, to: 'impersonations#stop_impersonating'
  end

  authenticate :user, ->(u) { u.admin? } do
    mount Que::Web, at: 'admin/que'
  end

  get :styleguide, to: 'application#styleguide' unless Rails.env.production?

  get '(.well-known)/apple-app-site-association', to: proc { [404, {}, ['']] }

  # Redirects
  %w[signup users].each { |path| get path, to: redirect('/sign_up') }
  get 'users/password', to: redirect('/passwords/new')

  root to: 'application#home'
end
