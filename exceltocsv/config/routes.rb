Rails.application.routes.draw do
  root 'reports#index'

  resources :reports do
    collection { 
      get :start_parse
      post :import 
    }
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

  resources :employees
    #post 'employees/:id' => 'employee#change_status', as: :change_status
    #post 'employees/:id/deactivate' => 'employee#deactivate'
end
