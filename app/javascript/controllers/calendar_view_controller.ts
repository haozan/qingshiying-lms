import { Controller } from "@hotwired/stimulus"

/**
 * Calendar View Controller
 * 
 * 显示月历视图，展示可预约时段
 * 
 * HTML Structure:
 *   <div data-controller="calendar-view"
 *        data-calendar-view-schedules-value='[...]'>
 *     <!-- calendar UI will be rendered here -->
 *   </div>
 * 
 * Values:
 *   - schedules (Array): 可预约时段数据
 *   - currentMonth (Number): 当前显示的月份
 *   - currentYear (Number): 当前显示的年份
 * 
 * Actions:
 *   - previousMonth: 切换到上个月
 *   - nextMonth: 切换到下个月
 *   - selectDate: 选择某一天
 */
export default class extends Controller {
  static values = {
    schedules: Array,
    currentMonth: Number,
    currentYear: Number,
    eligible: Boolean
  }

  static targets = ["calendar", "scheduleList"]

  declare schedulesValue: Array<any>
  declare currentMonthValue: number
  declare currentYearValue: number
  declare eligibleValue: boolean
  declare readonly calendarTarget: HTMLElement
  declare readonly scheduleListTarget: HTMLElement

  private selectedDate: Date | null = null
  private monthNames = ["一月", "二月", "三月", "四月", "五月", "六月", 
                        "七月", "八月", "九月", "十月", "十一月", "十二月"]
  private dayNames = ["日", "一", "二", "三", "四", "五", "六"]

  connect() {
    const today = new Date()
    if (!this.currentMonthValue) this.currentMonthValue = today.getMonth()
    if (!this.currentYearValue) this.currentYearValue = today.getFullYear()
    
    // Default select today
    this.selectedDate = today
    
    this.renderCalendar()
  }

  schedulesValueChanged() {
    this.renderCalendar()
  }

  previousMonth() {
    if (this.currentMonthValue === 0) {
      this.currentMonthValue = 11
      this.currentYearValue--
    } else {
      this.currentMonthValue--
    }
    this.renderCalendar()
  }

  nextMonth() {
    if (this.currentMonthValue === 11) {
      this.currentMonthValue = 0
      this.currentYearValue++
    } else {
      this.currentMonthValue++
    }
    this.renderCalendar()
  }

  selectDate(event: Event) {
    const target = event.currentTarget as HTMLElement
    const dateStr = target.dataset.date
    if (!dateStr) return

    this.selectedDate = new Date(dateStr)
    this.renderCalendar()
  }

  private renderCalendar() {
    this.calendarTarget.innerHTML = this.buildCalendarHTML()
    this.scheduleListTarget.innerHTML = this.buildScheduleListHTML()
  }

  private buildCalendarHTML(): string {
    const firstDay = new Date(this.currentYearValue, this.currentMonthValue, 1)
    const lastDay = new Date(this.currentYearValue, this.currentMonthValue + 1, 0)
    const daysInMonth = lastDay.getDate()
    const startDayOfWeek = firstDay.getDay()

    let html = `
      <div class="mb-4">
        <div class="flex items-center justify-between mb-4">
          <button type="button" 
                  data-action="click->calendar-view#previousMonth"
                  class="btn-ghost p-2 hover:bg-surface rounded-lg">
            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7"/>
            </svg>
          </button>
          <h3 class="text-xl font-bold text-foreground">
            ${this.currentYearValue}年 ${this.monthNames[this.currentMonthValue]}
          </h3>
          <button type="button"
                  data-action="click->calendar-view#nextMonth"
                  class="btn-ghost p-2 hover:bg-surface rounded-lg">
            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7"/>
            </svg>
          </button>
        </div>

        <!-- Day headers -->
        <div class="grid grid-cols-7 gap-1 mb-2">
          ${this.dayNames.map(day => `
            <div class="text-center text-sm font-medium text-muted py-2">
              ${day}
            </div>
          `).join('')}
        </div>

        <!-- Calendar days -->
        <div class="grid grid-cols-7 gap-1">
          ${this.buildCalendarDays(daysInMonth, startDayOfWeek)}
        </div>
      </div>
    `

    return html
  }

  private buildCalendarDays(daysInMonth: number, startDayOfWeek: number): string {
    let html = ''
    const today = new Date()
    today.setHours(0, 0, 0, 0)

    // Empty cells before first day
    for (let i = 0; i < startDayOfWeek; i++) {
      html += '<div class="aspect-square"></div>'
    }

    // Calendar days
    for (let day = 1; day <= daysInMonth; day++) {
      const currentDate = new Date(this.currentYearValue, this.currentMonthValue, day)
      const dateStr = this.formatDate(currentDate)
      const schedulesOnDay = this.getSchedulesForDate(dateStr)
      const isToday = currentDate.getTime() === today.getTime()
      const isSelected = this.selectedDate && 
                        currentDate.getTime() === this.selectedDate.getTime()
      const isPast = currentDate < today
      const hasSchedules = schedulesOnDay.length > 0

      let classes = 'aspect-square p-1 rounded-lg text-center cursor-pointer transition-colors '
      
      if (isPast) {
        classes += 'text-muted/50 cursor-not-allowed '
      } else if (isSelected) {
        classes += 'bg-primary text-white font-bold '
      } else if (hasSchedules) {
        classes += 'bg-primary/10 text-primary font-medium hover:bg-primary/20 '
      } else if (isToday) {
        classes += 'border-2 border-primary text-foreground hover:bg-surface '
      } else {
        classes += 'text-foreground hover:bg-surface '
      }

      html += `
        <div class="${classes}"
             data-date="${dateStr}"
             data-action="click->calendar-view#selectDate">
          <div class="text-sm">${day}</div>
          ${hasSchedules ? `<div class="text-xs mt-1">${schedulesOnDay.length}场</div>` : ''}
        </div>
      `
    }

    return html
  }

  private buildScheduleListHTML(): string {
    let schedules: Array<any>

    if (this.selectedDate) {
      const dateStr = this.formatDate(this.selectedDate)
      schedules = this.getSchedulesForDate(dateStr)
    } else {
      schedules = this.schedulesValue
    }

    if (schedules.length === 0) {
      return `
        <div class="text-center py-12 text-muted">
          <svg class="w-16 h-16 mx-auto mb-4 opacity-50" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z"/>
          </svg>
          <p class="text-lg font-medium">${this.selectedDate ? '该日期' : '当月'}暂无可预约时段</p>
        </div>
      `
    }

    return schedules.map(schedule => this.buildScheduleCard(schedule)).join('')
  }

  private buildScheduleCard(schedule: any): string {
    const alreadyBooked = schedule.already_booked
    const canBook = this.eligibleValue && schedule.bookable && !alreadyBooked

    let actionButton = ''
    if (alreadyBooked) {
      actionButton = '<span class="badge-success">已预约</span>'
    } else if (!this.eligibleValue) {
      actionButton = '<span class="badge badge-gray">需要购买课程</span>'
    } else if (!schedule.bookable) {
      actionButton = '<span class="badge badge-gray">已满员</span>'
    } else {
      actionButton = `
        <a href="/offline_bookings?offline_schedule_id=${schedule.id}"
           data-turbo-method="post"
           data-turbo-confirm="确定要预约此时段吗？"
           class="btn-primary">
          立即预约
        </a>
      `
    }

    return `
      <div class="card-elevated mb-4">
        <div class="card-body">
          <div class="flex items-center justify-between p-4">
            <div class="flex-1">
              <div class="flex items-center gap-4 mb-2">
                <div class="flex items-center gap-2 text-foreground font-medium">
                  <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z"/>
                  </svg>
                  ${schedule.date}
                </div>
                <div class="flex items-center gap-2 text-secondary">
                  <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z"/>
                  </svg>
                  ${schedule.time}
                </div>
              </div>
              <div class="flex items-center gap-2 text-sm text-muted">
                <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17.657 16.657L13.414 20.9a1.998 1.998 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0z"/>
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 11a3 3 0 11-6 0 3 3 0 016 0z"/>
                </svg>
                ${schedule.location}
              </div>
              <div class="mt-2 text-sm text-secondary">
                剩余名额: ${schedule.remaining} / ${schedule.max_attendees}
              </div>
            </div>
            <div>
              ${actionButton}
            </div>
          </div>
        </div>
      </div>
    `
  }

  private getSchedulesForDate(dateStr: string): Array<any> {
    return this.schedulesValue.filter(schedule => schedule.date === dateStr)
  }

  private formatDate(date: Date): string {
    const year = date.getFullYear()
    const month = String(date.getMonth() + 1).padStart(2, '0')
    const day = String(date.getDate()).padStart(2, '0')
    return `${year}-${month}-${day}`
  }
}
