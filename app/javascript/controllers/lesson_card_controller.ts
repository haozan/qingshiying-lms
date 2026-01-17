import { Controller } from "@hotwired/stimulus"

// 课程卡片翻转控制器
// 实现3D翻转动画: 正面显示学习内容, 背面显示作业提交
export default class extends Controller<HTMLElement> {
  static targets = ["card", "front", "back", "homeworkTextarea", "submitButton"]
  static values = {
    flipped: Boolean
  }

  declare readonly cardTarget: HTMLElement
  declare readonly frontTarget: HTMLElement
  declare readonly backTarget: HTMLElement
  declare readonly homeworkTextareaTarget: HTMLTextAreaElement
  declare readonly submitButtonTarget: HTMLButtonElement
  declare flippedValue: boolean

  connect(): void {
    console.log("LessonCard controller connected")
    
    // 如果已有作业内容，初始化时验证一次
    if (this.hasHomeworkTextareaTarget && this.hasSubmitButtonTarget) {
      this.validateHomework()
    }
  }

  // 翻转到作业面
  flipToHomework(): void {
    this.flippedValue = true
    this.cardTarget.style.transform = "rotateY(180deg)"
  }

  // 翻转回学习面
  flipToLesson(): void {
    this.flippedValue = false
    this.cardTarget.style.transform = "rotateY(0deg)"
  }

  // 切换翻转状态
  toggleFlip(): void {
    if (this.flippedValue) {
      this.flipToLesson()
    } else {
      this.flipToHomework()
    }
  }

  // 验证作业内容
  validateHomework(): void {
    const content = this.homeworkTextareaTarget.value.trim()
    
    if (content.length < 10) {
      this.submitButtonTarget.disabled = true
      this.submitButtonTarget.classList.add('opacity-50')
    } else {
      this.submitButtonTarget.disabled = false
      this.submitButtonTarget.classList.remove('opacity-50')
    }
  }
}
