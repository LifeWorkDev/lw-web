Rails.application.routes.draw do
  resource :user, only: %i[edit update]

  namespace :client, path: "c" do
    resource :org
    resources :milestone_projects do
      get :payment, on: :member
    end
    resources :pay_methods, except: :new do
      get :created, on: :collection
    end
    resources :projects, only: %i[index show] do
      resources :comments, only: :create
      member do
        patch :activate
        get :comments, to: redirect("/c/projects/%{id}/timeline")
        match :deposit, via: %i[get post]
        get :timeline
      end
    end
    resources :retainer_projects do
      get :payment, on: :member
    end
    get ":type/new", to: "pay_methods#new", constraints: {type: %w[bank_accounts cards]}
  end

  namespace :freelancer, path: "f" do
    resource :user, only: %i[edit update] do
      get :waitlist
    end
    resources :orgs, path: :clients
    resources :milestones
    resources :milestone_projects do
      member do
        get :milestones
        get :payment
      end
    end
    resources :projects do
      resources :comments, only: :create
      member do
        get :comments, to: redirect("/f/projects/%{id}/timeline")
        patch :invite
        get :preview
        match :status, via: %i[get patch]
        get :timeline
      end
    end
    resources :retainer_projects do
      get :payment, on: :member
    end
    scope controller: :content, as: :content, path: :content do
      get :walkthrough
    end
    scope controller: :stripe, as: :stripe, path: :stripe do
      get :callback
      get :connect
      get :dashboard
    end
    get :reports, to: "reports#index"
    get "reports/payments", to: "reports#payments"
  end

  resources :comments, only: :update

  %w[plaid stripe stripe_connect].each do |source|
    post "webhooks/#{source}", controller: :webhooks
  end

  as :user do
    get :login, to: "users/sessions#new", as: :new_user_session
    post :login, to: "users/sessions#create", as: :user_session
    delete :logout, to: "users/sessions#destroy", as: :destroy_user_session
    get :logout, to: "users/sessions#destroy"
  end
  devise_for :users,
             skip: [:sessions],
             controllers: {
               invitations: "users/invitations",
               registrations: "users/registrations",
               sessions: "users/sessions",
             }
  namespace :users do
    post ":id/impersonate", to: "impersonations#impersonate", as: :impersonate
    post :stop_impersonating, to: "impersonations#stop_impersonating"
  end

  authenticate :user, ->(u) { u.admin? } do
    mount Que::Web, at: "admin/que"
    unless Rails.env.development?
      get "admin/mailers", to: "rails/mailers#index"
      get "rails/mailers/*path", to: "rails/mailers#preview"
    end
  end

  get :styleguide, to: "application#styleguide" unless Rails.env.production?

  get "(.well-known)/apple-app-site-association", to: proc { [404, {}, [""]] }

  # Redirects
  ["signup", "sign_up", "users", "users/sign_up"].each { |path| get path, to: redirect("/login") }
  get "users/password", to: redirect("/passwords/new")

  root to: "authenticated#home"
end
