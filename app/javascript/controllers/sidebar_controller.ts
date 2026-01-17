import { Controller } from "@hotwired/stimulus"

// 侧边栏显示/隐藏控制器
// 用于学习页面的目录侧边栏切换
export default class extends Controller<HTMLElement> {
  static targets = ["sidebar", "overlay"]
  static values = {
    visible: Boolean
  }

  declare readonly sidebarTarget: HTMLElement
  declare readonly overlayTarget: HTMLElement
  declare visibleValue: boolean

  connect(): void {
    // 默认隐藏侧边栏，让内容卡片占据更多空间
    this.visibleValue = false
    this.updateSidebar()
  }

  // 切换侧边栏显示/隐藏
  toggle(): void {
    this.visibleValue = !this.visibleValue
    this.updateSidebar()
  }

  // 更新侧边栏状态
  private updateSidebar(): void {
    if (this.visibleValue) {
      // 显示侧边栏
      this.sidebarTarget.classList.remove('-translate-x-full')
      this.sidebarTarget.classList.add('translate-x-0')
      this.overlayTarget.classList.remove('hidden')
    } else {
      // 隐藏侧边栏
      this.sidebarTarget.classList.remove('translate-x-0')
      this.sidebarTarget.classList.add('-translate-x-full')
      this.overlayTarget.classList.add('hidden')
    }
  }
}
