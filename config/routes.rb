Rails.application.routes.draw do
  root "tv_shows#index"
  resources :tv_shows, only: [:index, :show]
  
  # Health check
  get "up" => "rails/health#show", as: :rails_health_check
end
