Rails.application.routes.draw do
  # Health check endpoint
  get '/health', to: proc { [200, {}, ['OK']] }

  # API routes
  namespace :api do
    namespace :v1 do
      # Auth endpoints
      post 'auth/login', to: 'auth#login'
      post 'auth/register', to: 'auth#register'
      
      # Purchases
      post 'purchases', to: 'purchases#create'
      get 'users/:rut/purchases', to: 'purchases#index'
      
      # User stats
      get 'users/:rut/stats', to: 'users#stats'
      
      # Rewards
      post 'rewards/redeem', to: 'rewards#redeem'
    end
  end
end
