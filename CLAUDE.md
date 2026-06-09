# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
# Start development server
bin/rails server

# Run all tests
bin/rails test

# Run a single test file
bin/rails test test/models/user_test.rb

# Run a single test by name
bin/rails test test/models/user_test.rb -n test_method_name

# Run system tests
bin/rails test:system

# Database
bin/rails db:migrate
bin/rails db:seed
bin/rails db:schema:load  # faster than running all migrations on a fresh DB

# Console
bin/rails console

# Assets
bin/rails assets:precompile

# Security scan
bundle exec brakeman

# Linting
bundle exec rubocop

# Annotate models with schema comments
bundle exec annotaterb models
```

## Architecture

This is a **Rails 7.2 app** for CDCH (Centro de Desarrollo Científico y Humanístico), a Venezuelan university research center. It serves two audiences:

1. **Public landing pages** (`PagesController`, `app/views/pages/`) — unauthenticated, shows institutional info, events, publications, etc.
2. **Dashboard** (`DashboardController` + `app/controllers/dashboard/`) — authenticated admin area for managing content.

### Authentication & Authorization

- **Devise** handles authentication. All controllers require login by default (`before_action :authenticate_user!` in `ApplicationController`). `PagesController` skips this.
- **CanCanCan** handles authorization via `app/models/ability.rb`. The `Ability` class derives permissions from `user.role` (delegated from `JobTitle`) and `UserPermission` records.

**Role hierarchy** (defined as integer-ordered enum on `JobTitle`, values 0–5):
- `Regular` (0) → read-only for own department
- `Coordinador` (1) → read own department
- `Administrador` (2) → manage own department
- `JefeDepartamento` (3) → read own department (DTIC department head gets `:manage, :all`)
- `Superadmin` (4) → full access (Director/Subdirector job titles are read-only even with Superadmin role)
- `Desarrollador` (5) → defined in enum but not handled in `Ability`; treated as `Regular` by default

The integer ordering is used in queries: `JobTitle.where("role <= ?", current_role_value)` when limiting selectable job titles.

**Fine-grained permissions** are stored in `user_permissions` table as tokens like `"Call:read"` or `"Publication:create"`. Resources scoped by `department_id` where available; `InstitutionLeadership` is an exception (not scoped by department). Valid resources: `Call`, `Event`, `Publication`, `Minute`, `Solicitude`, `InstitutionLeadership`. Valid actions: `read`, `create`, `update`.

### Key Models

- **`User`** — belongs to `Department` and `JobTitle`; role delegated from `JobTitle#role`; `active` boolean controls account activation (default `false`); `photoUser` via Active Storage
- **`JobTitle`** — holds the role enum (array form, so integer values map positionally); many job titles can share the same role
- **`Department`** — organizational units; `acronym` used for routing and business logic; `organize` integer for ordering; `description` is rich text; `logoDepartment` via Active Storage
- **`Institution`** — singleton; always use `Institution.first`; stores institutional metadata
- **`InstitutionLeadership`** — historical authority records; `role` enum `{ director: 0, subdirector: 1 }`; `active` is set automatically from `end_date` (blank = active); validates no overlapping date periods per role using PostgreSQL `daterange`; `bio` is rich text; `photo` via Active Storage
- **`Publication`** — `kind` enum `[:Otro, :Tesis, :Libro, :Revista, :Articulo]`; requires `portrait` image attachment; `publication_field` for the document file
- **`Solicitude`** — publicly creatable (unauthenticated route `POST /solicitudes`); managed only through the dashboard
- **`UserPermission`** — token format `"Resource:action"`; legacy tokens without `:action` are expanded to all three actions on read

### Dashboard Controllers

All under `app/controllers/dashboard/`, namespaced with `module: 'dashboard'` in routes. Pattern:
- `load_and_authorize_resource` at the top for per-action authorization
- Index actions additionally scope with `accessible_by(current_ability)` to filter the collection
- `UsersController` has extra logic: only `superadmin_role?` users can assign `UserPermission`s and see all departments/job titles

Shared dashboard view partials live directly in `app/views/dashboard/`: `_dashboard_form.html.erb` and `_table.html.erb`.

### Public Pages

`PagesController` actions map to views in `app/views/pages/`. URL slugs are in Spanish (e.g., `/direccion`, `/subdireccion`, `/galeria-autoridades`). Routing for departments uses the `acronym` field.

Layout partials for public pages live in `app/views/layouts/`: `_header.html.erb`, `_footer.html.erb`, `_sidebar.html.erb`, `_top_bar.html.erb`, `_CTA_section.html.erb`, `_counter.html.erb`.

### Frontend

- **Bootstrap 5** + custom SCSS in `app/assets/scss/` based on SB Admin 2 theme
- **Importmap** (no Node/webpack) with **Turbo**; `app/javascript/` contains only `application.js` and `sidebar.js` (no Stimulus controllers currently)
- **ActionText** (Trix editor) for rich text fields (`Department#description`, `InstitutionLeadership#bio`)
- **Active Storage** for file uploads; images processed via `mini_magick` / `ruby-vips`
- **will_paginate** for pagination (with Bootstrap styling via `will_paginate-bootstrap`)
- **Font Awesome** via `font-awesome-sass`

### Localization

All UI strings are in Spanish. `config/locales/es.yml` contains ActiveRecord model/attribute translations, flash messages, enum labels, and date/time formats. Use `t()` helpers in views for user-facing strings. Note: some older controllers still use hardcoded Spanish strings instead of i18n keys.

### Database

PostgreSQL. The app uses PostgreSQL-specific features:
- `daterange` overlap queries in `InstitutionLeadership`
- `COALESCE` and `Arel.sql` for custom ordering

### Special Conventions

- `Department#acronym` drives routing and business logic: `"Dir"` = Dirección, `"Subdir"` = Subdirección, `"DTIC"` = tech department with special admin privileges. Acronyms are stored and compared uppercased.
- `InstitutionLeadership` ordered via `.ordered_for_gallery` scope: by role (director first), then active records first, then most recent by end date
- Flash messages should use i18n keys: `t("flash.actions.create.notice", model: ...)`
- Model schema comments are auto-generated by `annotaterb` at the top of each model file; run `bundle exec annotaterb models` after migrations
