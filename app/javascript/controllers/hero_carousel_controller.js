import { Controller } from "@hotwired/stimulus"

// Carrusel de la portada: avanza solo cada 5 s, se pausa con el mouse encima
// y responde a los puntos y a las flechas del teclado.
export default class extends Controller {
  static targets = [ "slides", "slide", "dot" ]
  static values = { interval: { type: Number, default: 5000 } }

  connect() {
    this.index = 0
    if (this.slideTargets.length < 2) return

    this.keydown = (event) => {
      if (event.key === "ArrowLeft") this.previous()
      if (event.key === "ArrowRight") this.next()
    }
    document.addEventListener("keydown", this.keydown)
    this.play()
  }

  disconnect() {
    this.pause()
    if (this.keydown) document.removeEventListener("keydown", this.keydown)
  }

  next() {
    this.show(this.index + 1)
  }

  previous() {
    this.show(this.index - 1)
  }

  select(event) {
    this.show(Number(event.currentTarget.dataset.slide))
  }

  play() {
    if (this.slideTargets.length < 2) return
    this.pause()
    this.timer = setInterval(() => this.next(), this.intervalValue)
  }

  pause() {
    clearInterval(this.timer)
  }

  show(index) {
    const count = this.slideTargets.length
    this.index = (index + count) % count
    this.slidesTarget.style.transform = `translateX(${-this.index * 100}%)`
    this.dotTargets.forEach((dot, i) => dot.classList.toggle("active", i === this.index))
    this.play()
  }
}
