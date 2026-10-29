import { Controller } from "@hotwired/stimulus"

// Envía el formulario mientras se escribe (con pausa) o al cambiar un select.
export default class extends Controller {
  static values = { delay: { type: Number, default: 350 } }

  disconnect() {
    clearTimeout(this.timeout)
  }

  debounced() {
    clearTimeout(this.timeout)
    this.timeout = setTimeout(() => this.submit(), this.delayValue)
  }

  submit() {
    clearTimeout(this.timeout)
    this.element.requestSubmit()
  }
}
