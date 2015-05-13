Rails.application.routes.draw do
  root 'welcome#login'

  get "index", to: "welcome#index"
  get "login", :to => "welcome#login"
  get "logout", :to => "welcome#logout"
  post "login_attempt", to: "welcome#login_attempt"
  post "setting", :to => "welcome#setting"

  resources :reports do
    collection {
      post  :import
      post  :delete_all_records
      # get :loading_animation
    }
      get   :download_zip 
  end

  resources :employees do
    collection {
      post :import
    }
  end

  resources :users do
    get :activate
    get :deactivate
  end

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end
end
