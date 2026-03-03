Rails.application.routes.draw do
  devise_for :users
  devise_scope :user do
    get '/users/sign_out' => 'devise/sessions#destroy'
  end

  # Routes for Landing Pages
  get "contacto", to: "pages#contacto"
  get "convocatorias", to: "pages#convocatorias"
  get "convocatorias/:id", to: "pages#convocatorias", as: :convocatoria
  get "departamentos", to: "pages#departamentos"
  get "departamento/:acronym", to: "pages#departamento", as: :departamento
  get "direccion", to: "pages#direccion"
  get "subdireccion", to: "pages#subdireccion"
  get "actas", to: "pages#directorio"
  get "actas/:id", to: "pages#directorio", as: :acta
  get "eventos/:id", to: "pages#eventos", as: :evento
  get "eventos", to: "pages#eventos"
  get "inicio", to: "pages#inicio"
  get "investigacion", to: "pages#investigacion"
  get "nosotros", to: "pages#nosotros"
  get "publicaciones", to: "pages#publicaciones"
  resources :solicitudes, only: [:create] # Public Route for submitting solicitudes

  # Scaffold's Routes from Dashboard
  resources :announcements, module: 'dashboard'
  resources :calls, module: 'dashboard'
  resources :departments, module: 'dashboard'
  resources :institutions, module: 'dashboard', only: [:index, :show, :edit, :update]
  resources :job_titles, module: 'dashboard'
  resources :minutes, module: 'dashboard'
  resources :events, module: 'dashboard'
  resources :publications, module: 'dashboard'
  resources :solicitudes, module: 'dashboard', only: [:index, :show, :destroy]
  resources :users, module: 'dashboard'
  get "dashboard/index" # INDEX DASHBOARD


  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  # Defines the root path route ("/")
  root "pages#inicio"

  # match "*unmatched", to: "application#route_not_found", via: :all
end
