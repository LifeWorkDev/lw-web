Rails.application.routes.draw do
  as :user do
    get 'login', to: 'devise/sessions#new', as: :new_user_session
    post 'login', to: 'devise/sessions#create', as: :user_session
    delete 'logout', to: 'devise/sessions#destroy', as: :destroy_user_session
    get 'logout', to: 'devise/sessions#destroy'
    get 'sign_up', to: 'devise/registrations#new', as: :new_user_registration
  end
  devise_for :users, skip: [:sessions]
  namespace :users do
    get ':id/impersonate', to: 'impersonations#impersonate'
    get 'stop_impersonating', to: 'impersonations#stop_impersonating'
  end
  get 'users', to: redirect { Rails.application.routes.url_helpers.new_user_registration_path }
  get 'users/password', to: redirect { Rails.application.routes.url_helpers.new_user_password_path }

  get 'about_you', to: 'application#about_you'
  get 'milestones', to: 'application#milestones'
  get 'new_client', to: 'application#new_client'
  get 'styleguide', to: 'application#styleguide'

  get '(.well-known)/apple-app-site-association', to: proc { [404, {}, ['']] }
end
