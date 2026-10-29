// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"
import * as bootstrap from "bootstrap"
import "trix"
import "@rails/actiontext"
import * as ActiveStorage from "@rails/activestorage"

window.bootstrap = bootstrap
ActiveStorage.start()

// Los componentes con data-bs-* se enlazan solos; los tooltips no, y Turbo
// cambia el body en cada visita.
document.addEventListener("turbo:load", () => {
  document.querySelectorAll('[data-bs-toggle="tooltip"]').forEach((element) => {
    bootstrap.Tooltip.getOrCreateInstance(element)
  })
})

// Turbo guarda la página en caché antes de salir: que no queden abiertos
// offcanvas, modales ni tooltips en la copia.
document.addEventListener("turbo:before-cache", () => {
  document.querySelectorAll(".offcanvas.show, .modal.show").forEach((element) => {
    element.classList.remove("show")
  })
  document.querySelectorAll(".offcanvas-backdrop, .modal-backdrop, .tooltip").forEach((element) => element.remove())
  document.body.classList.remove("modal-open")
  document.body.style.removeProperty("overflow")
  document.body.style.removeProperty("padding-right")
})
