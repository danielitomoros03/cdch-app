# CDCH APP
# Aplicación desarrollada por Daniel Moros

Aplicacion web institucional del **Consejo de Desarrollo Cientifico y Humanistico (CDCH - UCV)**.

Combina:
- Sitio público informativo (inicio, eventos, convocatorias, departamentos, contacto, etc.).
- Dashboard administrativo autenticado para gestionar contenido, usuarios y solicitudes.

## 1. Versiones y Stack Tecnico

Versiones principales:
- Ruby: `3.1.2` (`.ruby-version`)
- Rails: `7.2.2.1` (`Gemfile.lock`)
- Bundler: `2.4.4` (`Gemfile.lock`)
- Base de datos: PostgreSQL (`pg ~> 1.1`)
- Servidor web: Puma (`puma >= 5.0`, lock en `6.6.0`)

Gemas/tecnologias clave:
- Autenticacion: `devise`
- Autorizacion: `cancancan`
- Rich Text: `ActionText` + `trix`
- Archivos: `ActiveStorage` (servicio local)
- Frontend: `bootstrap 5`, `sassc-rails`, `font-awesome-sass`, `jquery-rails`
- Navegacion SPA-like: `turbo-rails`, `stimulus-rails` (Hotwire)
- Paginacion: `will_paginate`, `will_paginate-bootstrap`
- I18n: `rails-i18n`, `i18n-tasks`

### 1.1 Gemas y para que sirve cada una en esta app

Runtime/app:
- `rails`: framework principal MVC.
- `sprockets-rails`: pipeline de assets (CSS/JS/imagenes) usado por la app.
- `pg`: adaptador de PostgreSQL para ActiveRecord.
- `puma`: servidor HTTP de Rails.
- `importmap-rails`: carga de JS sin bundler (import maps).
- `turbo-rails`: navegacion y rendering dinamico (Hotwire/Turbo).
- `stimulus-rails`: controlador JS ligero para comportamiento UI.
- `jbuilder`: soporte para respuestas JSON estructuradas en controladores.
- `tzinfo-data`: zonas horarias en plataformas que lo requieren.
- `bootsnap`: acelera arranque por cache de carga.
- `rails-i18n`: traducciones/formatos i18n de Rails.
- `i18n-tasks`: auditoria y mantenimiento de llaves de traduccion.
- `image_processing`: transformaciones de imagen para ActiveStorage.
- `mini_magick`: backend ImageMagick para procesado de imagen.
- `ruby-vips`: backend Vips para procesado de imagen.
- `will_paginate`: paginacion en listados (ej. actas).
- `will_paginate-bootstrap`: estilos bootstrap para paginacion.
- `devise`: login/logout y sesiones de usuarios.
- `bootstrap`: framework CSS base de UI.
- `jquery-rails`: soporte jQuery usado por assets legacy.
- `font-awesome-sass`: iconografia del dashboard/sitio.
- `sassc-rails`: compilacion SCSS en pipeline.
- `cancancan`: autorizacion por reglas (`Ability`).

Development/Test:
- `debug`: debugging local.
- `brakeman`: analisis de seguridad para Rails.
- `rubocop-rails-omakase`: lint y estilo Ruby/Rails.
- `web-console`: consola interactiva en errores de desarrollo.
- `annotaterb`: anotaciones de schema en modelos.
- `error_highlight`: mejora de mensajes de error en Ruby.
- `capybara`: pruebas de sistema/UI.
- `selenium-webdriver`: driver browser para tests de sistema.

## 2. Configuracion Global

En `config/application.rb`:
- `config.load_defaults 7.2`
- Locale por defecto: `:es`
- Zona horaria: `Caracas`

En `config/environments/production.rb`:
- `config.force_ssl = true`
- `config.assets.compile = false`
- Host permitido: `silenia.ucv.ve`

## 3. Como Funciona la Aplicacion

### 3.1 Flujo general

1. Un visitante entra al sitio publico (root en `pages#inicio`).
2. Puede navegar convocatorias, actas, departamentos, eventos, publicaciones y contacto.
3. Desde contacto puede enviar una solicitud publica (`Solicitude`).
4. Usuarios internos inician sesion con Devise y son redirigidos a `dashboard#index`.
5. El dashboard muestra estadisticas y accesos rapidos segun permisos.
6. Cada CRUD del dashboard se filtra por autorizacion (`Ability` + `accessible_by`).

### 3.2 Sitio publico

Controlador: `PagesController` (sin autenticacion).

Secciones principales:
- `inicio`
- `convocatorias` / `convocatoria/:id`
- `actas` / `actas/:id`
- `eventos` / `eventos/:id`
- `publicaciones`
- `departamentos` / `departamento/:acronym`
- `direccion`, `subdireccion`, `nosotros`, `contacto`, `investigacion`, `galeria-autoridades`

Comportamiento destacado:
- Inicio muestra hero de eventos con `show_in: true` y cards de departamentos.
- Convocatorias, eventos y actas manejan vista listado + detalle por `id`.
- Contacto muestra informacion institucional (`Institution.first`) y formulario publico de solicitudes.

### 3.3 Dashboard interno

Controladores bajo `app/controllers/dashboard/`:
- `CallsController`
- `MinutesController`
- `PublicationsController`
- `EventsController`
- `DepartmentsController`
- `InstitutionsController`
- `UsersController`
- `SolicitudesController`
- `AnnouncementsController`
- `JobTitlesController`

Patron comun en la mayoria de controladores:
- `load_and_authorize_resource` (CanCanCan)
- consultas con `Model.accessible_by(current_ability)`
- CRUD con `strong params`

Nota:
- `JobTitlesController` actualmente no declara `load_and_authorize_resource` de forma explicita.

`DashboardController#index` construye KPIs de:
- Convocatorias
- Publicaciones
- Actas
- Usuarios

con comparacion mensual (`delta`) y estilo visual segun crecimiento/disminucion.

### 3.4 Autenticacion y autorizacion

Autenticacion:
- Globalmente se exige login en `ApplicationController` (`before_action :authenticate_user!`).
- Excepciones publicas:
	- `PagesController`
	- `SolicitudesController#create`
	- `ApplicationController#route_not_found`

Autorizacion por roles (`Ability`):
- `Superadmin`:
	- Si el cargo es Director/Subdirector: `read :all`.
	- En otros casos: `manage :all`.
- `Administrador`: gestiona su propio departamento.
- `JefeDepartamento`:
	- Si pertenece a `DTIC`: `manage :all`.
	- En otros departamentos: acceso limitado de lectura de su area.
- `Coordinador`: lectura de su departamento.
- Otros usuarios: lectura de usuarios/departamento propios.

Permisos granulares adicionales:
- Tabla `user_permissions` (token `"Resource:action"`).
- Recursos soportados: `Call`, `Event`, `Publication`, `Minute`, `Solicitude`.
- Acciones soportadas: `read`, `create`, `update`.
- El form de usuarios permite marcar permisos por recurso/accion para perfiles avanzados.

### 3.5 Funciones especificas clave (qué hace cada una)

Control de sesion y errores:
- `ApplicationController#after_sign_in_path_for`: redirige a `dashboard/index` al iniciar sesion.
- `ApplicationController#after_sign_out_path_for`: redirige a login al cerrar sesion.
- `ApplicationController#route_not_found`: maneja rutas invalidas y redirige con mensaje.

Estadisticas del dashboard:
- `DashboardController#build_stats_for(model)`: calcula total, conteo mensual y delta para un modelo.
- `DashboardController#delta_text_for`: texto humano del cambio mensual.
- `DashboardController#delta_class_for`: clase CSS segun tendencia.
- `DashboardController#delta_icon_for`: icono segun tendencia.

Logica publica principal:
- `PagesController#inicio`: carga departamentos destacados, eventos activos y hero.
- `PagesController#convocatorias`: listado o detalle de convocatoria segun `params[:id]`.
- `PagesController#eventos`: listado o detalle de evento segun `params[:id]`.
- `PagesController#directorio`: listado paginado de actas o detalle.
- `PagesController#departamento`: detalle de departamento, jefe y personal asociado.

Solicitud publica:
- `SolicitudesController#create`: recibe formulario de contacto y crea `Solicitude`.
- `SolicitudesController#solicitude_params`: parametros permitidos del formulario.

Usuarios y permisos:
- `UsersController#set_collections`: arma listas de departamentos/cargos segun rol del usuario actual.
- `UsersController#extract_resource_permissions`: valida tokens de permisos seleccionados.
- `UsersController#sync_user_permissions`: sincroniza permisos en DB al crear/editar usuario.
- `UsersController#superadmin_role?`: detecta perfil con permisos avanzados.

Autorizacion por reglas:
- `Ability#initialize(user)`: define reglas globales por rol, departamento y permisos granulares.

Modelo de permisos:
- `UserPermission.parse_token`: interpreta `resource:action` y detecta formato legacy.
- `UserPermission.valid_token?`: valida token permitido.
- `UserPermission.expand_tokens`: normaliza tokens legacy a formato explicito.
- `UserPermission#resource_class`: retorna clase Ruby asociada al token.

Metodos utilitarios de dominio:
- `User#full_name`: concatena nombre y apellido.
- `Call#desactive`: desactiva convocatorias vencidas por fecha.
- `Call#timeLeft`: dias restantes hasta cierre de convocatoria.
- `Institution#phone_numbers`: concatena telefonos principal/secundario.
- `Institution#emails`: concatena correos principal/secundario.
- `Department#send_director` y metodos `send_*`: ubican usuarios por cargo dentro del departamento.

## 4. Dominio de Datos (Resumen)

Modelos principales:
- `User`: autenticacion Devise, pertenece a `Department` y `JobTitle`, avatar con ActiveStorage (`photoUser`).
- `JobTitle`: catalogo de cargos con enum de rol logico.
- `Department`: departamentos institucionales, descripcion rich text y logo adjunto.
- `Institution`: datos institucionales globales (se usa `Institution.first`).
- `Call`: convocatorias con rich text (`large_description`) y enum `kind`.
- `Event`: noticias/eventos con rich text (`content`), imagen adjunta y enum `kind`.
- `Minute`: actas con rich text (`content`) y archivo adjunto.
- `Publication`: publicaciones con archivo adjunto y enum `kind`.
- `Solicitude`: solicitudes publicas enviadas desde contacto.
- `Announcement`: anuncios internos.
- `UserPermission`: permisos por recurso/accion para control fino.

Enums relevantes:
- `JobTitle.role`: `Regular`, `Coordinador`, `Administrador`, `JefeDepartamento`, `Superadmin`, `Desarrollador`
- `Call.kind`: `Convocatoria`, `Festividad`, `Noticia`
- `Event.kind`: `Noticia`, `Ahora`, `Eventualidad`, `Jornada`, `Otro`
- `Publication.kind`: `Otro`, `Tesis`, `Libro`, `Revista`, `Articulo`

## 5. Rutas Importantes

Publicas:
- `GET /` -> `pages#inicio`
- `GET /contacto`
- `GET /convocatorias`, `GET /convocatorias/:id`
- `GET /actas`, `GET /actas/:id`
- `GET /eventos`, `GET /eventos/:id`
- `GET /departamento/:acronym`
- `POST /solicitudes`

Autenticadas:
- `GET /dashboard/index`
- Recursos dashboard: `/calls`, `/minutes`, `/publications`, `/events`, `/departments`, `/institutions`, `/users`, `/solicitudes`, etc.

Tecnicas:
- `GET /up` health check
- `GET /service-worker`
- `GET /manifest`
- Catch-all de rutas no encontradas con redireccion controlada

## 6. Frontend y Assets

Motor visual:
- Sprockets + SCSS (`app/assets/stylesheets/application.scss`)
- Bootstrap 5 personalizado por variables SCSS
- Font Awesome para iconografia

Javascript:
- `app/javascript/application.js`: bootstrap, trix, actiontext, turbo, sidebar
- `app/javascript/sidebar.js`: toggle de sidebar y offcanvas

Layout:
- `app/views/layouts/application.html.erb`
- Header dinamico para visitante vs usuario autenticado
- Sidebar del dashboard con items condicionados por `can?`

## 7. Base de Datos

Adapter:
- PostgreSQL en todos los entornos (`config/database.yml`)

Bases por entorno:
- Development: `app_development`
- Test: `app_test`
- Production: `app_production`

Extensiones:
- `plpgsql` habilitada en schema.

## 8. Seeds Incluidos

`db/seeds.rb` crea datos base completos:
- Departamentos estandar CDCH
- Cargos (`JobTitle`) con rol logico
- Usuarios iniciales
- Institucion base (`Institution`)
- Publicaciones, actas, convocatorias, eventos, anuncios

Nota:
- Existen usuarios de ejemplo con contrasena simple (`123123`) para entorno de desarrollo/demo.
- Cambiar credenciales y politicas de seguridad antes de cualquier despliegue real.

## 9. Requisitos de Entorno

Minimos recomendados:
- Ruby `3.1.2`
- Bundler `2.4.4`
- PostgreSQL activo
- Node/npm no son obligatorios para importmap, pero pueden ser utiles para tooling adicional

Variables de entorno utiles:
- `RAILS_ENV`
- `RAILS_MAX_THREADS`
- `PORT`
- `RAILS_MASTER_KEY` (especialmente en produccion/Docker)
- `REDIS_URL` (Action Cable en produccion)
- `RAILS_LOG_LEVEL`

## 10. Instalacion Local

### Opcion A: setup automatico

```bash
bin/setup
```

Este script:
- instala dependencias gem
- prepara base de datos
- limpia logs/temp
- reinicia servidor

### Opcion B: setup manual

```bash
bundle install
bin/rails db:create
bin/rails db:migrate
bin/rails db:seed
bin/rails server
```

Aplicacion disponible en:
- `http://localhost:3000`

## 11. Pruebas y Calidad

Suite de pruebas (Minitest):
- tests de modelos
- tests de controladores
- tests de sistema

Comandos:

```bash
bin/rails test
bin/rails test:system
```

Analisis de codigo y seguridad:

```bash
bin/rubocop
bin/brakeman
```

## 12. Docker (Produccion)

El `Dockerfile` esta orientado a produccion (multi-stage build).

Build:

```bash
docker build -t cdch-app .
```

Run:

```bash
docker run -d -p 3000:3000 --name cdch-app -e RAILS_MASTER_KEY=<tu_master_key> cdch-app
```

Notas:
- Se precompilan assets en build.
- Se ejecuta con usuario no root.
- `ENTRYPOINT` usa `bin/docker-entrypoint` para preparar DB.

## 13. Servicios Internos

ActiveStorage (`config/storage.yml`):
- `local` (development/production actual)
- `test` (tmp/storage)

Action Cable (`config/cable.yml`):
- development: `async`
- test: `test`
- production: `redis` (`REDIS_URL`)

Active Job:
- No hay backend externo configurado actualmente (usa comportamiento default de Rails).

## 14. Estructura del Proyecto

Directorios clave:
- `app/controllers` controladores publicos y dashboard
- `app/models` logica de negocio y autorizacion
- `app/views` UI publica + dashboard + devise
- `app/javascript` JS con importmap
- `app/assets` estilos, imagenes y manifiestos
- `config` rutas, entornos, i18n, storage, cable
- `db` migraciones, schema, seeds
- `test` suite Minitest

## 15. Observaciones Operativas

- El host de produccion esta orientado a `silenia.ucv.ve`.
- Hay pagina de healthcheck en `/up`.
- Existe manejo centralizado de rutas no encontradas con redireccion amigable.
- La informacion institucional de muchas vistas depende de que exista al menos un registro en `Institution`.

---

Si necesitas, puedo agregar en este mismo README:
- diagrama de arquitectura (publico vs dashboard),
- matriz completa rol -> recurso -> accion,
- guia de despliegue en servidor Linux paso a paso.
