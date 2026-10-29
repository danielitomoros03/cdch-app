import { Controller } from "@hotwired/stimulus"
import { Tooltip } from "bootstrap"

// Menú lateral del panel: se contrae a solo íconos y recuerda la preferencia en
// una cookie, para que el servidor lo pinte ya contraído y no parpadee.
export default class extends Controller {
  static targets = [ "link", "toggle" ]
  static classes = [ "collapsed" ]

  connect() {
    this.syncTooltips()
  }

  disconnect() {
    this.linkTargets.forEach((link) => Tooltip.getInstance(link)?.dispose())
  }

  toggle() {
    const collapsed = this.element.classList.toggle(this.collapsedClass)
    document.cookie = `sidebar=${collapsed ? "collapsed" : "expanded"}; path=/; max-age=31536000; SameSite=Lax`
    this.toggleTargets.forEach((button) => button.setAttribute("aria-expanded", String(!collapsed)))
    this.syncTooltips()
  }

  // Con el menú contraído, el nombre de cada enlace aparece al pasar el mouse.
  syncTooltips() {
    const collapsed = this.element.classList.contains(this.collapsedClass)
    this.linkTargets.forEach((link) => {
      if (collapsed) {
        Tooltip.getOrCreateInstance(link, { placement: "right", trigger: "hover" })
      } else {
        Tooltip.getInstance(link)?.dispose()
      }
    })
  }
}
