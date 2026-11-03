Rails.application.routes.draw do
  resources :time_off_requests, only: [ :new, :create ]
  root "businesses#new"

  resources :businesses, only: [ :new, :create, :show ] do
    resources :invitations, only: [ :new, :create ]
    resources :schedule_weeks, only: [ :index, :show ] do
      patch :publish, on: :member
      resources :shifts, only: [ :new, :create ]
    end
    resource :upcoming_shifts, only: :show
  end

  resource :session, only: [ :new, :create, :destroy ]
  get "invitations/accept/:token", to: "invitations#accept", as: :accept_invitation
  post "invitations/accept/:token", to: "invitations#join"

  get "up" => "rails/health#show", as: :rails_health_check
end
