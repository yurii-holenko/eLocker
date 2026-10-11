Rails.application.routes.draw do
  # Health check for load balancers / uptime monitors. Returns 200 if the app boots.
  get "up" => "rails/health#show", as: :rails_health_check

  root "lockers#index"

  resources :lockers, only: :index do
    resources :actions, only: :create, controller: "locker_actions"
  end

  resource :session, only: :update
  resource :locale, only: :update

  if Rails.env.development?
    require "sidekiq/web"
    mount Sidekiq::Web => "/sidekiq"
  end
end
