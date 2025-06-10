Rails.application.routes.draw do
  # Health check endpoint
  get '/health', to: 'health#show'
  
  # API routes
  namespace :api do
    namespace :v1 do
      resources :tv_shows do
        resources :episodes
      end
      
      resources :distributors do
        resources :tv_shows, only: [:index]
      end
      
      resources :users do
        resources :tv_shows, only: [:index, :create, :destroy]
      end
      
      # Analytics endpoints
      namespace :analytics do
        get :episode_stats, to: 'analytics#episode_stats'
        get :distribution_analysis, to: 'analytics#distribution_analysis'
        get :genre_performance, to: 'analytics#genre_performance'
      end
    end
  end
  
  # Root route
  root 'api/v1/tv_shows#index'
end
