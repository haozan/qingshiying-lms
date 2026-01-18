import { Controller } from "@hotwired/stimulus"

/**
 * View Toggle Controller
 * 
 * 在列表视图和日历视图之间切换
 * 
 * HTML Structure:
 *   <div data-controller="view-toggle">
 *     <button data-view-toggle-target="button" 
 *             data-view="list"
 *             data-action="click->view-toggle#switch">列表</button>
 *     <button data-view-toggle-target="button"
 *             data-view="calendar" 
 *             data-action="click->view-toggle#switch">日历</button>
 *     
 *     <div data-view-toggle-target="content" data-view="list">...</div>
 *     <div data-view-toggle-target="content" data-view="calendar">...</div>
 *   </div>
 */
export default class extends Controller {
  static targets = ["button", "content"]

  declare readonly buttonTargets: HTMLElement[]
  declare readonly contentTargets: HTMLElement[]

  private currentView: string = "calendar"

  connect() {
    // Initialize with calendar view
    this.showView("calendar")
  }

  switch(event: Event) {
    const button = event.currentTarget as HTMLElement
    const view = button.dataset.view
    
    if (view && view !== this.currentView) {
      this.showView(view)
    }
  }

  private showView(view: string) {
    this.currentView = view

    // Update buttons
    this.buttonTargets.forEach(button => {
      if (button.dataset.view === view) {
        button.classList.add("bg-primary", "text-white")
        button.classList.remove("text-secondary", "hover:text-foreground")
      } else {
        button.classList.remove("bg-primary", "text-white")
        button.classList.add("text-secondary", "hover:text-foreground")
      }
    })

    // Update content
    this.contentTargets.forEach(content => {
      if (content.dataset.view === view) {
        content.classList.remove("hidden")
      } else {
        content.classList.add("hidden")
      }
    })
  }
}
