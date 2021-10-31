Rails.application.routes.draw do
  devise_for :users, controllers: {
    sessions: 'users/sessions',
    registrations: 'users/registrations'
  }
  devise_scope :user do
    get 'sign_in', to: 'users/sessions#new'
    get 'sign_up', to: 'users/registrations#new'
    get 'sso/new', to: 'users/sessions#auth'
    get 'sso/callback', to: 'users/sessions#callback'
  end

  root to: 'application#home'

  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
