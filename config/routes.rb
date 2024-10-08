Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  root "dashboard#index"

  devise_for :users,
    controllers: {
      confirmations: "users/confirmations",
      passwords: "users/passwords",
      unlocks: "users/unlocks",
      sessions: "users/sessions"
    },
    path: "admin",
    path_names: {
      sign_in: "login",
      sign_out: "logout",
      confirmations: "confirmation",
      password: "password-reset",
      unlock: "unlock"
    }

  get "admin", to: "admin#index"
  scope "/admin" do
    get "switch-dashboard", to: "admin#switch_dashboard"
    resource :messages, only: [ :create ]
    resources :services, only: %i[index new create edit update destroy] do
      member do
        get "delete"
      end
    end
    resources :users, only: %i[index show new create edit update destroy] do
      member do
        get "delete"
      end
    end
  end

  get "/(:scope)",
    to: "dashboard#index",
    as: "dashboard",
    constraints: ->(r) { %w[internal external].include?(r.params[:scope]) }

  match "*path", to: "application#not_found", via: :all unless Rails.env.development?
end
