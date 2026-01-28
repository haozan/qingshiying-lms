import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="countdown"
// Targets: daysTarget, hoursTarget, minutesTarget, secondsTarget
// Values: deadlineValue (ISO 8601 datetime string)
export default class extends Controller<HTMLElement> {
  static targets = ["days", "hours", "minutes", "seconds"]
  static values = {
    deadline: String
  }

  declare readonly daysTarget: HTMLElement
  declare readonly hoursTarget: HTMLElement
  declare readonly minutesTarget: HTMLElement
  declare readonly secondsTarget: HTMLElement
  declare readonly deadlineValue: string

  private intervalId: number | null = null

  connect(): void {
    this.updateCountdown()
    this.intervalId = window.setInterval(() => {
      this.updateCountdown()
    }, 1000)
  }

  disconnect(): void {
    if (this.intervalId) {
      clearInterval(this.intervalId)
    }
  }

  private updateCountdown(): void {
    const deadline = new Date(this.deadlineValue)
    const now = new Date()
    const diff = deadline.getTime() - now.getTime()

    if (diff <= 0) {
      this.daysTarget.textContent = "0"
      this.hoursTarget.textContent = "00"
      this.minutesTarget.textContent = "00"
      this.secondsTarget.textContent = "00"
      if (this.intervalId) {
        clearInterval(this.intervalId)
      }
      return
    }

    const days = Math.floor(diff / (1000 * 60 * 60 * 24))
    const hours = Math.floor((diff % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60))
    const minutes = Math.floor((diff % (1000 * 60 * 60)) / (1000 * 60))
    const seconds = Math.floor((diff % (1000 * 60)) / 1000)

    this.daysTarget.textContent = String(days)
    this.hoursTarget.textContent = String(hours).padStart(2, "0")
    this.minutesTarget.textContent = String(minutes).padStart(2, "0")
    this.secondsTarget.textContent = String(seconds).padStart(2, "0")
  }
}
