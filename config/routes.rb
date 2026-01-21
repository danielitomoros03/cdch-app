Rails.application.routes.draw do
  devise_for :users
  devise_scope :user do
    get '/users/sign_out' => 'devise/sessions#destroy'
  end

  
  # Routes for Landing Pages
  get "contacto", to: "pages#contacto"
  get "convocatorias", to: "pages#convocatorias"
  get "departamentos", to: "pages#departamentos"
  get "actas", to: "pages#directorio"
  get "eventos", to: "pages#eventos"
  get "inicio", to: "pages#inicio"
  get "investigacion", to: "pages#investigacion"
  get "nosotros", to: "pages#nosotros"
  get "publicaciones", to: "pages#publicaciones"
  
  # Scaffold's Routes from Dashboard
  resources :users, module: 'dashboard' # Admin-managed users
  resources :calls, module: 'dashboard'
  resources :minutes, module: 'dashboard'
  resources :publications, module: 'dashboard'
  
  # Rutas internas de la aplicación
  get "dashboard/index"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  # Defines the root path route ("/")
  root "pages#inicio"
end
