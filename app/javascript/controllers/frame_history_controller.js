import { Controller } from "@hotwired/stimulus"
import { Turbo } from "@hotwired/turbo-rails"

// Un turbo-frame con data-turbo-action="advance" agrega entradas al historial,
// pero Turbo no repinta nada al volver atrás entre ellas. Si el botón Atrás o
// Adelante deja al navegador en esta misma ruta, se vuelve a pedir la página
// para que los filtros y los resultados coincidan con la URL.
export default class extends Controller {
  connect() {
    this.path = window.location.pathname
    this.restore = () => {
      if (window.location.pathname === this.path) Turbo.visit(window.location.href, { action: "replace" })
    }
    window.addEventListener("popstate", this.restore)
  }

  disconnect() {
    window.removeEventListener("popstate", this.restore)
  }
}
