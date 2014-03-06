Reech::Application.routes.draw do

  namespace :api, defaults: {format: 'json'} do
    namespace :v1 do
      
      resources :users
        post "signup" => "users#create", :as => "signup"

      resources :user_sessions
        post "logout_user" => "user_sessions#destroy", :as => "logout_user"
        post "login_user" => "user_sessions#create", :as => "login_user"

      # devise_for :users, skip: :all
      # devise_scope :api_user do
      #   post "/register", :to => "users#create"
      #   post "/login", :to => "sessions#create"
      #   get "/login", :to => "user_sessions#new"
      #   post "/logout", :to => "sessions#destroy"
      # end


      # to override devise controllers, must copy devise_controller.rb from gem into app
      # devise_for :users, :controllers => {
      #   :registrations => 'api/v1/users',
      #   :sessions => 'devise/sessions',
      #   :passwords => 'devise/passwords',
      #   :confirmations => 'devise/confirmations',
      #   :unlocks => 'devise/unlocks'
      # }

      resources :questions     
        post "question_feed" => "questions#index"
      
      resources :solutions
      
      resources :user_profile
      post "/connections" => "user_profile#showconnections", :as=>"connections"
      post "/changepassword" => "user_profile#changepass", :as=>"changepassword"

      resources :friendships do
        collection do
          get 'req',:as=>"addfriend"
          get 'accept',:as=>"accept_fr"
          get 'reject',:as=>"reject_fr"
        end
      end

     
      # resources :authorizations
      # post '/auth/:provider/callback' => 'authorizations#create'
      # get '/auth/failure' => 'authorizations#failure'
      # post '/auth/:provider' => 'authorizations#create'
      # get '/auth' => 'authorizations#index'
      # get '/auth/password/callback' => 'user_sessions#new'
      
      
      

      # post 'user_profile/update/:reecher_id', :to => 'user_profile#update', :as => :update_reecher_profile, :via => [:post]
    end
  end

 
  # WebApp routes


  resources :questions do
    resources :solutions
  end
  resources :users

  resources :messages do
    collection do
      get 'compose', :to=>'messages#new', :as=>:compose
      get 'index', :to=> 'messages#index', :as=> :index
      get 'sent', :to=> 'messages#sent', :as=> :sent
      post 'reply', :to=> 'messages#reply', :as=> :reply
      post 'trash', :to=> 'messages#trash', :as=> :trash
    end
  end

  resource :reech do
    collection do
      get 'home'
      get 'loadmorequestions'
    end
  end
  
  resources :user_sessions
  resources :authorizations
  match '/auth/:provider/callback' => 'authorizations#create'
  match '/auth/failure' => 'authorizations#failure'
  match '/auth/:provider' => 'authorizations#blank'
  get '/auth/password/callback' => 'user_sessions#new'

  resources :newsfeeds
  root :to => 'reech#home'
  resources :chats


  get  '/sbchat' => 'chats#index', :as => :chat
  post '/new_message' => 'chats#new_message', :as => :new_message
  
  get  "refresh"  => "reech#refreshquestions", :as => "refresh"
  
  #voting mechanism for each post - disabled for now
  #get "votedup"  => "reech#votedup", :as => "votedup"
  #get  "voteddown"  => "reech#voteddown", :as => "voteddown"

  #Sessions & Users & Profile
  get "logout_user" => "user_sessions#destroy", :as => "logout_user"
  get "login_user" => "user_sessions#new", :as => "login_user"
  get "signup" => "users#new", :as => "signup"
  match "/myconnections/:reecher_id" => "users#showconnections", :as=>"myconnections"
  match :profile, :to => 'user_profile#index', :as=>:about
  match 'user_profile/update/:reecher_id', :to => 'user_profile#update', :as => :update_reecher_profile, :via => [:post]

  resources :friendships do
    collection do
      get 'req',:as=>"addfriend"
      get 'accept',:as=>"accept_fr"
      get 'reject',:as=>"reject_fr"
    end
  end
 


  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
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

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :solutions, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :solutions
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end


  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
end
