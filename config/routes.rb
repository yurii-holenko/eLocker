Rails.application.routes.draw do
  # Health check for load balancers / uptime monitors. Returns 200 if the app boots.
  get "up" => "rails/health#show", as: :rails_health_check

  root "home#index"

  if Rails.env.development?
    require "sidekiq/web"
    mount Sidekiq::Web => "/sidekiq"
  end
end
