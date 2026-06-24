Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "home#index"

  post :delivery_request, to: "delivery_request#create"
  patch "driver/location", to: "driver_location#update"
  patch "driver/requests/:id/respond", to: "driver_requests#respond", as: :driver_requests_respond

  get   "deliveries",            to: "deliveries#index",         as: :deliveries
  get   "deliveries/:id",        to: "deliveries#show",          as: :delivery
  get   "deliveries/:id/events", to: "deliveries#events",        as: :delivery_events
  patch "deliveries/:id/status", to: "deliveries#update_status", as: :deliveries_update_status

  namespace :auth do
    post :login, to: "sessions#create"
    post :register, to: "registrations#create"
  end
end
