Rails.application.routes.draw do
  devise_for :users

  resources :readings do
    collection do
      get :recommend
      post :predict_reason
    end
  end

  resources :books, only: [:new, :create] do
    collection do
      get :search
      post :create_from_google_books
    end
  end

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  root "readings#index"
end
