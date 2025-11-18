# frozen_string_literal: true

Rails.application.routes.draw do
  # Preview emails in development
  mount LetterOpenerWeb::Engine, at: '/letter_opener' if Rails.env.development?

  devise_for :users, controllers: {
    registrations: 'users/registrations'
  }

  # ユーザー関連ページ
  get 'users/registration_complete', to: 'users#registration_complete', as: :users_registration_complete
  get 'profile', to: 'users#profile', as: :profile

  resources :readings do
    collection do
      get :recommend
      post :predict_reason
    end
  end

  resources :books, only: %i[new create] do
    collection do
      get :search
      get :autocomplete
      post :create_from_google_books
    end
  end

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get 'up' => 'rails/health#show', as: :rails_health_check

  # TOPページ
  root 'pages#home'

  # お問い合わせ
  get "/footers/contact_form", to: "footers#contact_form"
  post "/footers/contact_form", to: "footers#create"
end
