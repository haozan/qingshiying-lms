import { Controller } from "@hotwired/stimulus"

/**
 * Qiniu Video Player Controller
 * 
 * Targets:
 * - container: video player container element
 * 
 * Values:
 * - url: video URL from Qiniu
 * - lessonId: current lesson ID for progress tracking
 * 
 * Actions:
 * - connect: initialize Qiniu player
 * - disconnect: cleanup player instance
 */
export default class extends Controller {
  static targets = ["container"]
  static values = {
    url: String,
    lessonId: Number
  }

  declare readonly containerTarget: HTMLElement
  declare readonly urlValue: string
  declare readonly lessonIdValue: number

  private player: any = null
  private progressInterval: number | null = null

  connect() {
    if (!this.urlValue) {
      console.warn("Qiniu player: no video URL provided")
      return
    }

    this.initializePlayer()
  }

  disconnect() {
    this.cleanup()
  }

  private initializePlayer() {
    // Check if Qiniu SDK is loaded
    if (typeof (window as any).qiniuPlayer === 'undefined') {
      this.showFallbackPlayer()
      return
    }

    try {
      // Initialize Qiniu player
      // Docs: https://developer.qiniu.com/pili/8770/web-player
      this.player = new (window as any).qiniuPlayer({
        container: this.containerTarget,
        url: this.urlValue,
        autoplay: false,
        controls: true,
        preload: 'metadata',
        width: '100%',
        height: '100%'
      })

      // Track video progress
      this.player.on('timeupdate', () => {
        this.trackProgress()
      })

      // Mark as completed when video ends
      this.player.on('ended', () => {
        this.markVideoCompleted()
      })

    } catch (error) {
      console.error("Failed to initialize Qiniu player:", error)
      this.showFallbackPlayer()
    }
  }

  private showFallbackPlayer() {
    // Fallback to native HTML5 video player
    this.containerTarget.innerHTML = `
      <video 
        src="${this.urlValue}" 
        controls 
        preload="metadata"
        class="w-full h-full rounded-lg"
        style="background: #000;">
        您的浏览器不支持视频播放
      </video>
    `
  }

  private trackProgress() {
    if (!this.player) return

    // Throttle progress updates (every 10 seconds)
    if (this.progressInterval) return

    this.progressInterval = window.setTimeout(() => {
      const currentTime = this.player.currentTime()
      const duration = this.player.duration()
      
      if (duration > 0) {
        const progress = Math.floor((currentTime / duration) * 100)
        this.updateServerProgress(progress)
      }

      this.progressInterval = null
    }, 10000)
  }

  private updateServerProgress(progress: number) {
    // Silent background update - no UI feedback needed
    // Video progress is tracked automatically without user interaction
  }

  private markVideoCompleted() {
    // Silent background update - no UI feedback needed
    // Completion is tracked automatically when video ends
  }

  private cleanup() {
    if (this.progressInterval) {
      clearTimeout(this.progressInterval)
      this.progressInterval = null
    }

    if (this.player && typeof this.player.dispose === 'function') {
      this.player.dispose()
      this.player = null
    }
  }

  private get csrfToken(): string {
    const meta = document.querySelector('meta[name="csrf-token"]')
    return meta ? meta.getAttribute('content') || '' : ''
  }
}
