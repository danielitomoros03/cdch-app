# Auditoría de Seguridad — cdch-app

**Fecha:** 2026-05-20
**Alcance:** Rails 7.2.2 (cdch-app), revisión estática manual + Brakeman 7.0.0
**Versiones revisadas:** Ruby 3.1.2, Devise, CanCanCan, ActionText, Active Storage

---

## Resumen ejecutivo

| #  | Severidad | Tema                                                                              |
|----|-----------|-----------------------------------------------------------------------------------|
| 1  | Crítico   | `JobTitlesController` sin autorización → escalada a Superadmin                    |
| 2  | Alto      | XSS almacenado vía `Institution.*_url` (sin validar `javascript:`)                |
| 3  | Alto      | Mass assignment de `role` / `job_title_id` sin validación server-side             |
| 4  | Alto      | Endpoints públicos sin rate-limit (solicitudes, login, reset)                     |
| 5  | Alto      | Active Storage acepta cualquier MIME (SVG-XSS, ejecutables)                       |
| 6  | Medio     | Contraseñas mínimas de 6 caracteres                                               |
| 7  | Medio     | Sin Devise `:lockable` → brute force                                              |
| 8  | Medio     | Content Security Policy desactivada                                               |
| 9  | Medio     | `mailer_sender` por defecto rompe recuperación de contraseña                      |
| 10 | Medio     | Ruby 3.1.2 fuera de soporte (EOL 2025-03-31)                                      |
| 11 | Medio     | `Permissions-Policy` desactivada                                                  |
| 12 | Medio     | `require_master_key` comentado en producción                                      |
| 13 | Bajo      | `Event/Call/Minute.find` sin rescue en `PagesController`                          |
| 14 | Bajo      | `pages_controller` rompe si faltan job titles "Subdirector" / "Secretario(a)"     |
| 15 | Bajo      | Enumeración de Events/Calls/Minutes inactivos por ID                              |
| 16 | Bajo      | `UserPermission` token "legacy" mapea a `:manage`                                 |
| 17 | Bajo      | Varios endurecimientos menores                                                    |

**Prioridad inmediata antes de exponer la app a Internet:** arreglar 1, 2, 5 y 4. Las tres primeras son explotables sin condiciones especiales; (4) protege la disponibilidad y los buzones administrativos.

---

## CRÍTICO

### 1. Escalada de privilegios vía `JobTitlesController` sin `load_and_authorize_resource`

**Archivo:** `app/controllers/dashboard/job_titles_controller.rb:2-3`
**CLAUDE.md dice:** *"All under `app/controllers/dashboard/` ... They use CanCanCan's `load_and_authorize_resource` pattern"* — `JobTitlesController` es el único que **no** lo declara.

**Impacto:** cualquier usuario autenticado (incluido rol `Regular`) puede:
- `POST /job_titles` con `{ name: "x", role: 4 }` → crear un cargo con rol `Superadmin`
- `PATCH /job_titles/:id` con `{ role: 4 }` → cambiar el `role` del cargo que tiene asignado (el suyo propio) y obtener `manage :all` instantáneamente porque `User.delegate :role, to: :job_title`.

**Fix:**

```ruby
# app/controllers/dashboard/job_titles_controller.rb
class Dashboard::JobTitlesController < ApplicationController
  before_action :set_job_title, only: %i[show edit update destroy]
  load_and_authorize_resource   # <- añadir
  # ...
end

# app/models/ability.rb — restringir gestión a Superadmin real
can :manage, JobTitle if role == "Superadmin" && !%w[Director Subdirector].include?(job_title_name)
```

Por defecto CanCanCan denegará todo lo demás, así que con solo añadir la línea ya queda cerrado para roles inferiores; la regla explícita en `Ability` es defensa en profundidad.

---

## ALTO

### 2. XSS almacenado vía URLs de `Institution`

**Archivos:**
- `app/models/institution.rb` — sin validación de formato/esquema
- `app/views/layouts/_footer.html.erb:28-43`
- `app/views/pages/contacto.html.erb:73-90`
- `app/views/dashboard/institutions/show.html.erb:117-152`

`facebook_url`, `twitter_url`, `instagram_url`, `linkedin_url`, `threads_url`, `youtube_url` se renderizan como `href` sin sanitizar el esquema. `form.url_field` solo valida HTML5 (cliente). Un admin con permiso de editar Institution puede guardar `javascript:fetch('/x?c='+document.cookie)` por curl y queda persistido. Brakeman flagueó `youtube_url`; el resto son igualmente vulnerables.

**Fix:**

```ruby
# app/models/institution.rb
SOCIAL_URL_ATTRS = %i[facebook_url twitter_url instagram_url linkedin_url threads_url youtube_url].freeze

validates(*SOCIAL_URL_ATTRS,
          allow_blank: true,
          format: { with: %r{\Ahttps?://}i, message: "debe empezar con http(s)://" })
```

### 3. Mass assignment de `role` y `job_title_id`

**Archivos:**
- `app/controllers/dashboard/job_titles_controller.rb:69` — `permit(:name, :role)` (flagueado por Brakeman)
- `app/controllers/dashboard/users_controller.rb:99-114` — `permit(..., :job_title_id, :department_id, ...)`
- `app/controllers/dashboard/institution_leaderships_controller.rb:63` — `permit(..., :role, ...)` (flagueado por Brakeman, falso positivo: aquí `role` es director/subdirector, no rol de aplicación)

`set_collections` en `UsersController` restringe **dropdowns** pero no los parámetros. Hoy solo Superadmin y DTIC-JefeDepartamento llegan al `update`, pero la defensa depende del UI: cualquier futuro permiso de `manage User` para roles inferiores abre escalada inmediata.

**Fix:** validar en el controller que `job_title_id` y `department_id` ∈ colecciones permitidas.

```ruby
def user_params
  permitted = params.require(:user).permit(...)
  if permitted[:job_title_id].present? && @job_titles.none? { |jt| jt.id.to_s == permitted[:job_title_id].to_s }
    permitted.delete(:job_title_id)
  end
  if permitted[:department_id].present? && @departments.none? { |d| d.id.to_s == permitted[:department_id].to_s }
    permitted.delete(:department_id)
  end
  permitted
end
```

### 4. Endpoints públicos sin rate-limit ni CAPTCHA

**Archivos:** `app/controllers/solicitudes_controller.rb` (POST público), rutas de Devise (`/users/sign_in`, `/users/password`).

- `POST /solicitudes` puede inundarse a saturar la tabla `solicitudes`.
- Sin `:lockable` (ver #7) ni rate-limit, login y reset son brute-force-ables.

**Fix:** añadir `rack-attack` con throttles por IP/parámetro.

```ruby
# Gemfile
gem "rack-attack"

# config/initializers/rack_attack.rb
class Rack::Attack
  throttle("solicitudes/ip", limit: 5, period: 1.hour) do |req|
    req.ip if req.path == "/solicitudes" && req.post?
  end
  throttle("logins/ip", limit: 10, period: 5.minutes) do |req|
    req.ip if req.path == "/users/sign_in" && req.post?
  end
  throttle("logins/email", limit: 5, period: 20.minutes) do |req|
    req.params.dig("user", "email").to_s.downcase.presence if req.path == "/users/sign_in" && req.post?
  end
end
```

Considerar reCAPTCHA invisible o `invisible_captcha` gem en el formulario de solicitudes.

### 5. Active Storage sin validación de Content-Type

**Archivos:** todos los `has_one_attached` excepto `Publication#portrait`:
- `User#photoUser` — `app/models/user.rb`
- `Department#logoDepartment`
- `Institution#logoInstitution`, `logoDirection`
- `InstitutionLeadership#photo`
- `Event#image`
- `Minute#attachment_minute`

Con `config.active_storage.service = :local` (production.rb:34) los archivos se sirven desde el mismo dominio. Un SVG con `<script>` se ejecuta en el origen → XSS. Tampoco hay límite de tamaño.

**Fix (ejemplo en `User`):**

```ruby
validate :photo_user_must_be_image

private

def photo_user_must_be_image
  return unless photoUser.attached?
  unless photoUser.content_type.in?(%w[image/png image/jpeg image/jpg image/webp])
    errors.add(:photoUser, "debe ser JPG, PNG o WEBP")
  end
  if photoUser.byte_size > 5.megabytes
    errors.add(:photoUser, "no debe superar 5 MB")
  end
end
```

Replicar para cada modelo. Para `Minute#attachment_minute` (PDF/doc), whitelist explícita: `application/pdf`, etc.

---

## MEDIO

### 6. Política de contraseñas débil

**Archivo:** `config/initializers/devise.rb:11` — `config.password_length = 6..128`.

**Fix:** `config.password_length = 12..128`. Considerar `devise-security` para complejidad (mayúscula/número/símbolo) y rotación.

### 7. Sin Devise `:lockable`

**Archivo:** `app/models/user.rb:21` — solo `:database_authenticatable, :recoverable, :rememberable, :validatable`.

**Fix:**

```ruby
# app/models/user.rb
devise :database_authenticatable, :recoverable, :rememberable, :validatable, :lockable

# Migración
add_column :users, :failed_attempts, :integer, default: 0, null: false
add_column :users, :unlock_token,    :string
add_column :users, :locked_at,       :datetime
add_index  :users, :unlock_token, unique: true

# config/initializers/devise.rb
config.lock_strategy     = :failed_attempts
config.unlock_strategy   = :email
config.maximum_attempts  = 10
config.unlock_in         = 1.hour
```

### 8. Content Security Policy desactivada

**Archivo:** `config/initializers/content_security_policy.rb` — todo comentado.

**Fix mínimo:**

```ruby
Rails.application.configure do
  config.content_security_policy do |policy|
    policy.default_src :self
    policy.font_src    :self, :data, "https://fonts.gstatic.com"
    policy.img_src     :self, :data, :https
    policy.object_src  :none
    policy.script_src  :self, :https
    policy.style_src   :self, :https, :unsafe_inline   # mientras dependa de Trix/Bootstrap inline styles
    policy.frame_src   "https://www.google.com"        # para el iframe del mapa
    policy.frame_ancestors :self
    policy.base_uri :self
  end
  config.content_security_policy_nonce_generator = ->(request) { request.session.id.to_s }
  config.content_security_policy_nonce_directives = %w(script-src)
end
```

Empezar en `report_only` y promover a enforce tras probar.

### 9. `mailer_sender` por defecto

**Archivo:** `config/initializers/devise.rb:2` — `'please-change-me-at-config-initializers-devise@example.com'`.

Los emails de "olvidé mi contraseña" salen con este remitente — los servidores SMTP los rechazan o los marcan spam. Esto **rompe la recuperación de contraseña en producción**.

**Fix:** `config.mailer_sender = 'no-reply@cdch.ucv.ve'` y configurar `action_mailer.smtp_settings` en `production.rb`.

### 10. Ruby 3.1.2 fuera de soporte

**Archivo:** `.ruby-version`. Soporte terminado 2025-03-31. Sin parches de seguridad.

**Fix:** subir a 3.3.x mínimo. Verificar compatibilidad de gems en `Gemfile.lock`.

### 11. `Permissions-Policy` desactivada

**Archivo:** `config/initializers/permissions_policy.rb`.

```ruby
Rails.application.config.permissions_policy do |policy|
  policy.camera     :none
  policy.microphone :none
  policy.geolocation :none
  policy.usb        :none
end
```

### 12. `require_master_key` opcional

**Archivo:** `config/environments/production.rb:21`. Si en producción falta `RAILS_MASTER_KEY`, la app arranca sin credenciales (Devise pepper, `secret_key_base`) → sesiones inválidas, mailer roto.

**Fix:** descomentar `config.require_master_key = true`.

---

## BAJO

### 13. `find` sin rescue en páginas públicas

**Archivo:** `app/controllers/pages_controller.rb:5, 22, 86, 112`. IDs inválidos en `eventos`, `convocatorias`, `directorio` lanzan `RecordNotFound` → 500. Solo `publicaciones` está rescatado.

**Fix:** `rescue_from ActiveRecord::RecordNotFound, with: :redirect_with_alert` a nivel del controller, o `find_by` con guard.

### 14. `pages_controller` rompe si faltan JobTitles "clave"

**Archivo:** `app/controllers/pages_controller.rb:53, 58-59`.

`JobTitle.find_by(name: "Subdirector").id` → `NoMethodError` si el registro no existe. Una vez cerrado el hallazgo #1, deja de ser un DoS trivial sobre la home pública, pero igual conviene defender:

```ruby
subdirector_id = JobTitle.find_by(name: "Subdirector")&.id
@other_users = User.where(department_id: @subdirection.id)
@other_users = @other_users.where.not(job_title_id: subdirector_id) if subdirector_id
```

### 15. Enumeración de Events/Calls/Minutes inactivos por ID

**Archivo:** `app/controllers/pages_controller.rb:5, 22, 86, 112`.

`render :evento` / `:convocatoria` no filtran por `active`. Si "inactivo" significa "borrador / no publicar todavía", esto es information disclosure.

**Fix:**

```ruby
@event = Event.where(active: true).find(params[:id])
# o, si solo Superadmin puede ver inactivos:
scope = current_user&.role == "Superadmin" ? Event.all : Event.where(active: true)
@event = scope.find(params[:id])
```

### 16. Token "legacy" en `UserPermission` mapea a `:manage`

**Archivo:** `app/models/user_permission.rb:88-96`.

Si quedan filas con `resource` sin `:action` (formato antiguo, p. ej. `"Call"`), `parse_token` lo interpreta como `permission_action: :manage`. Más permisivo de lo que el UI sugiere.

**Fix:** migración de datos a formato `"Recurso:accion"` y endurecer la validación para rechazar tokens legacy.

### 17. Endurecimientos menores

- **`link_to "#{Institution.first.facebook_url}"`** (footer/contacto): la interpolación con `#{}` convierte `nil` en `""` → `href=""` reenvía a la página actual. Usar `Institution.first.facebook_url` directo + guard `if .present?`.
- **`Department#cut_acronym`** (`app/models/department.rb`): método privado nunca llamado por callback. Eliminar o ligarlo con `before_validation`.
- **`User#active` no se chequea en sign-in.** Si la intención era poder desactivar usuarios sin borrarlos, hoy un usuario "inactivo" sigue pudiendo entrar. Añadir `def active_for_authentication?; super && active?; end` y migración para tratar `false` por defecto.
- **`filter_parameter_logging.rb`** incluye `:email` en los filtros. Útil para PII, pero dificulta depurar logins fallidos. Opinable.
- **`PagesController` no maneja `params[:id]` no numérico** en `find` — Rails 7 acepta strings, pero validar formato evita 500s por scraping.

---

## Resultados de Brakeman (referencia)

Ejecutado con `bundle exec brakeman` (versión 7.0.0):

| Categoría                   | Confianza | Archivo                                                                  |
|----------------------------|-----------|--------------------------------------------------------------------------|
| EOL Ruby                   | High      | `.ruby-version:1` (→ hallazgo #10)                                       |
| Mass Assignment (`:role`)  | Medium    | `dashboard/institution_leaderships_controller.rb:63` (falso positivo)    |
| Mass Assignment (`:role`)  | Medium    | `dashboard/job_titles_controller.rb:69` (→ hallazgo #3)                  |
| XSS LinkToHref             | Weak      | `_footer.html.erb:41`, `pages/contacto.html.erb:86` (→ hallazgo #2)      |
| XSS LinkToHref             | Weak      | `pages/publicacion.html.erb:52` (validación http(s) en modelo, seguro)   |

---

## Plan de remediación sugerido

**Sprint 1 (bloqueante, antes de exponer públicamente):**
1. Hallazgo #1 — autorización en `JobTitlesController` (≈ 5 líneas)
2. Hallazgo #2 — validar URLs de Institution
3. Hallazgo #5 — validar Content-Type en todos los `has_one_attached`
4. Hallazgo #4 — rack-attack en login + solicitudes

**Sprint 2 (endurecimiento):**
5. Hallazgo #3 — validación server-side de `job_title_id` / `department_id`
6. Hallazgo #7 — Devise `:lockable`
7. Hallazgo #6 — `password_length 12..128`
8. Hallazgo #9 — `mailer_sender` real + SMTP en producción
9. Hallazgo #12 — `require_master_key = true`
10. Hallazgo #8 — CSP en `report_only`, luego enforce

**Sprint 3 (limpieza):**
11. Hallazgo #10 — actualizar Ruby
12. Hallazgo #11 — Permissions-Policy
13. Hallazgos #13–#17 — endurecimientos menores

---

## Notas para auditorías futuras

- Re-correr `bundle exec brakeman` en cada PR (integrar en CI).
- Revisar `Ability#initialize` después de cualquier cambio en roles/permisos: la mezcla de enum + `UserPermission` + casos especiales (`DTIC`, Director/Subdirector como read-only Superadmin) es propensa a regresiones.
- Cualquier nuevo controller en `app/controllers/dashboard/` debe declarar `load_and_authorize_resource` — considerar un linter o un test que recorra `Dashboard.constants` y verifique la presencia del callback.
