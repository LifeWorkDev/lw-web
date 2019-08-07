Rails.application.routes.draw do
  resources :milestones
  resources :orgs
  resources :projects do
    get 'milestones', on: :member
    get 'payments', on: :member
  end
  resource :user, only: %i[edit update]

  as :user do
    get 'login', to: 'devise/sessions#new', as: :new_user_session
    post 'login', to: 'devise/sessions#create', as: :user_session
    delete 'logout', to: 'devise/sessions#destroy', as: :destroy_user_session
    get 'logout', to: 'devise/sessions#destroy'
    get 'sign_up', to: 'devise/registrations#new', as: :new_user_registration
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

  root to: redirect('/sign_up')
end
