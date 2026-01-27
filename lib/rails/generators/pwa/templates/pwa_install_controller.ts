import { Controller } from "@hotwired/stimulus"

interface BeforeInstallPromptEvent extends Event {
  readonly platforms: string[]
  readonly userChoice: Promise<{
    outcome: 'accepted' | 'dismissed'
    platform: string
  }>
  prompt(): Promise<void>
}

/**
 * PWA Install Controller
 *
 * Handles Progressive Web App installation prompt
 *
 * Usage:
 *   <div data-controller="pwa-install">
 *     <button
 *       data-pwa-install-target="installButton"
 *       data-action="click->pwa-install#install"
 *       class="hidden">
 *       Install App
 *     </button>
 *   </div>
 */
export default class extends Controller {
  declare readonly installButtonTarget: HTMLButtonElement
  declare readonly hasInstallButtonTarget: boolean

  private deferredPrompt: BeforeInstallPromptEvent | null = null
  private boundBeforeInstallPrompt!: (e: Event) => void
  private boundAppInstalled!: () => void

  connect() {
    this.boundBeforeInstallPrompt = this.handleBeforeInstallPrompt.bind(this)
    this.boundAppInstalled = this.handleAppInstalled.bind(this)
    
    window.addEventListener('beforeinstallprompt', this.boundBeforeInstallPrompt)
    window.addEventListener('appinstalled', this.boundAppInstalled)

    if (this.isStandalone()) {
      this.hideInstallButton()
    }
  }

  disconnect() {
    window.removeEventListener('beforeinstallprompt', this.boundBeforeInstallPrompt)
    window.removeEventListener('appinstalled', this.boundAppInstalled)
  }

  private handleBeforeInstallPrompt(e: Event) {
    e.preventDefault()
    this.deferredPrompt = e as BeforeInstallPromptEvent

    if (this.hasInstallButtonTarget) {
      this.installButtonTarget.classList.remove('hidden')
    }
  }

  private handleAppInstalled() {
    this.deferredPrompt = null
    this.hideInstallButton()
  }

  async install() {
    // 如果还没有收到 beforeinstallprompt 事件，等待一段时间
    if (!this.deferredPrompt) {
      // 等待最多 2 秒让 beforeinstallprompt 事件触发
      const maxWaitTime = 2000
      const checkInterval = 100
      let waited = 0

      while (!this.deferredPrompt && waited < maxWaitTime) {
        await new Promise(resolve => setTimeout(resolve, checkInterval))
        waited += checkInterval
      }

      // 等待后仍然没有收到事件，说明浏览器不支持
      if (!this.deferredPrompt) {
        if (typeof window.showToast === 'function') {
          window.showToast('您的浏览器暂不支持安装应用，请使用 Chrome、Edge 或 Safari 浏览器访问', 'warning')
        } else {
          alert('您的浏览器暂不支持安装应用，请使用 Chrome、Edge 或 Safari 浏览器访问')
        }
        return
      }
    }

    this.deferredPrompt.prompt()

    const { outcome } = await this.deferredPrompt.userChoice

    if (outcome === 'accepted') {
      console.log('PWA installation accepted')
    }

    this.deferredPrompt = null
    this.hideInstallButton()
  }

  private isStandalone(): boolean {
    return window.matchMedia('(display-mode: standalone)').matches ||
           (window.navigator as any).standalone === true
  }

  private hideInstallButton() {
    if (this.hasInstallButtonTarget) {
      this.installButtonTarget.classList.add('hidden')
    }
  }

  static targets = ["installButton"]
}
