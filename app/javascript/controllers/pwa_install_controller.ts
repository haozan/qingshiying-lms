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

  connect() {
    window.addEventListener('beforeinstallprompt', this.handleBeforeInstallPrompt.bind(this))
    window.addEventListener('appinstalled', this.handleAppInstalled.bind(this))

    // 如果已经在 PWA 模式下运行，隐藏安装按钮
    if (this.isStandalone()) {
      this.hideInstallButton()
    }
    // 否则按钮始终显示，等待 beforeinstallprompt 事件或用户点击
  }

  disconnect() {
    window.removeEventListener('beforeinstallprompt', this.handleBeforeInstallPrompt.bind(this))
    window.removeEventListener('appinstalled', this.handleAppInstalled.bind(this))
  }

  private handleBeforeInstallPrompt(e: Event) {
    e.preventDefault()
    this.deferredPrompt = e as BeforeInstallPromptEvent
    // 不需要手动显示按钮，因为现在默认就是显示的
  }

  private handleAppInstalled() {
    this.deferredPrompt = null
    this.hideInstallButton()
  }

  async install() {
    // 如果浏览器不支持 PWA 安装，给出提示
    if (!this.deferredPrompt) {
      alert('您的浏览器暂不支持安装应用。\n\n请使用 Chrome、Edge 或 Safari 浏览器访问。')
      return
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
