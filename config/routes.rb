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
  get "galeria-autoridades", to: "pages#galeria_autoridades", as: :galeria_autoridades
  get "galeria-autoridades-v2", to: "pages#galeria_autoridades_v2", as: :galeria_autoridades_v2
  get "publicaciones", to: "pages#publicaciones"
  get "publicaciones/:id", to: "pages#publicaciones", as: :publicacion
  resources :solicitudes, only: [:create] # Public Route for submitting solicitudes

  # Scaffold's Routes from Dashboard
  resources :announcements, module: 'dashboard'
  resources :calls, module: 'dashboard'
  resources :departments, module: 'dashboard'
  resources :institutions, module: 'dashboard', only: [:index, :show, :edit, :update]
  resources :institution_leaderships, module: 'dashboard'
  resources :job_titles, module: 'dashboard'
  resources :minutes, module: 'dashboard'
  resources :events, module: 'dashboard'
  resources :publications, module: 'dashboard'
  resources :solicitudes, module: 'dashboard', only: [:index, :show, :destroy]
  resources :users, module: 'dashboard' do
    patch :unlock, on: :member
  end
  resources :people, module: 'dashboard', only: [:index, :show], path: 'docentes'
  resources :research_projects, module: 'dashboard', only: [:show], path: 'proyectos'
  get "dashboard/index" # INDEX DASHBOARD
  resource :general_setup, module: "dashboard", only: [ :show, :update ], path: "configuracion" do
    post :test_email
  end

  # "Mi espacio" del docente: entra con cédula + fecha de ingreso, sin cuenta de usuario.
  scope "mi-espacio", module: "teacher_space" do
    get "/", to: "profiles#show", as: :teacher_space
    patch "/", to: "profiles#update"
    get "entrar", to: "sessions#new", as: :new_teacher_session
    post "entrar", to: "sessions#create", as: :teacher_session
    delete "salir", to: "sessions#destroy", as: :destroy_teacher_session
  end


  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  # Defines the root path route ("/")
  root "pages#inicio"

  match "*unmatched", to: "application#route_not_found", via: :all,
        constraints: lambda { |request|
          request.format.html? &&
            !request.path.start_with?("/assets", "/rails/active_storage", "/favicon.ico", "/robots.txt")
        }
end
