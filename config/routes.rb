Rails.application.routes.draw do
  as :user do
    get 'login', to: 'devise/sessions#new', as: :new_user_session
    post 'login', to: 'devise/sessions#create', as: :user_session
    delete 'logout', to: 'devise/sessions#destroy', as: :destroy_user_session
    get 'logout', to: 'devise/sessions#destroy'
    get 'signup', to: 'devise/registrations#new', as: :new_user_registration
  end
  devise_for :users, skip: [:sessions]
  namespace :users do
    get ':id/impersonate' => 'impersonations#impersonate'
    get 'stop_impersonating' => 'impersonations#stop_impersonating'
  end

  root to: 'application#home'
end
