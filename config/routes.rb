Rails.application.routes.draw do
  # Health check endpoint
  get '/health', to: proc { [200, {}, ['OK']] }

  # API routes
  namespace :api do
    namespace :v1 do
      # Auth endpoints
      post 'auth/login', to: 'auth#login'
      post 'auth/register', to: 'auth#register'
      get 'auth/status', to: 'auth#status'
      post 'auth/logout', to: 'auth#logout'
      
      # Purchases
      post 'purchases', to: 'purchases#create'
      get 'users/:rut/purchases', to: 'purchases#index'
      get 'users/:rut/purchases/recent', to: 'purchases#recent'
      
      # User profile, stats and stamps
      get 'users/:rut/stats', to: 'users#stats'
      get 'users/:rut/stamps', to: 'users#stamps'
      put 'users/:rut', to: 'users#update'
      
      # User QR code
      get 'users/:rut/qr', to: 'users#qr'
      
      # User redemptions history
      get 'users/:rut/redemptions', to: 'users#redemptions'
      
      # Rewards
      get 'rewards', to: 'rewards#index'
      post 'rewards/redeem', to: 'rewards#redeem'
      post 'users/:rut/redeem', to: 'rewards#redeem_by_user'
      
      # Locations
      get 'locations', to: 'locations#index'
      
      # Notifications
      get 'users/:rut/notifications', to: 'notifications#index'
      put 'users/:rut/notifications/read_all', to: 'notifications#mark_all_as_read'
      put 'notifications/:id/read', to: 'notifications#mark_as_read'
      
      # Contact form
      post 'contact', to: 'contact#create'
      
      # POS (Point of Sale) endpoints
      post 'pos/scan', to: 'pos#scan'
    end
  end
end
