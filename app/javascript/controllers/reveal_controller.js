import { Controller } from "@hotwired/stimulus"

// Anima los elementos .reveal cuando entran en pantalla (animate.css).
export default class extends Controller {
  connect() {
    this.observer = new IntersectionObserver((entries) => {
      entries.forEach((entry) => {
        if (entry.isIntersecting) {
          entry.target.classList.add("active", "animate__animated")
        }
      })
    }, { threshold: 0.1 })

    this.element.querySelectorAll(".reveal").forEach((element) => this.observer.observe(element))
  }

  disconnect() {
    this.observer?.disconnect()
  }
}
