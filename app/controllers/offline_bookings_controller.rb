class OfflineBookingsController < ApplicationController
  before_action :authenticate_user!, except: [:index]
  before_action :check_offline_booking_eligible, only: [:create]

  def index
    @schedules = OfflineSchedule.available.includes(:course, :offline_bookings).order(schedule_date: :asc, schedule_time: :asc)
    
    if current_user
      @my_bookings = current_user.offline_bookings.confirmed
                                  .joins(:offline_schedule)
                                  .merge(OfflineSchedule.upcoming)
                                  .order('offline_schedules.schedule_date', 'offline_schedules.schedule_time')
      @eligible = current_user.offline_booking_eligible?
      @expires_at = current_user.offline_booking_expires_at
      @no_show_count = current_user.no_show_count_this_year
      @banned = current_user.banned_from_booking?
      @remaining_chances = current_user.remaining_no_show_chances
    else
      @my_bookings = []
      @eligible = false
      @expires_at = nil
      @no_show_count = 0
      @banned = false
      @remaining_chances = 3
    end
  end

  def create
    @schedule = OfflineSchedule.find(params[:offline_schedule_id])
    
    unless @schedule.bookable?
      redirect_to offline_bookings_path, alert: '该场次不可预约' and return
    end
    
    @booking = current_user.offline_bookings.new(
      offline_schedule: @schedule,
      status: 'confirmed'
    )
    
    if @booking.save
      @schedule.increment!(:current_attendees)
      if @schedule.full?
        @schedule.update!(status: 'full')
      end
      success_message = "预约成功！您已预约：#{@schedule.schedule_date.strftime('%Y年%m月%d日')} #{@schedule.schedule_time} - #{@schedule.location}"
      redirect_to offline_bookings_path, notice: success_message
    else
      redirect_to offline_bookings_path, alert: @booking.errors.full_messages.join(', ')
    end
  end

  def destroy
    @booking = current_user.offline_bookings.find(params[:id])
    @schedule = @booking.offline_schedule
    
    # 检查48尊时窗口
    unless @booking.can_cancel?
      redirect_to offline_bookings_path, alert: '无法取消预约：距离预约时间不足48小时，无法取消' and return
    end
    
    @booking.cancel!
    @schedule.decrement!(:current_attendees)
    
    if @schedule.status == 'full' && !@schedule.full?
      @schedule.update!(status: 'available')
    end
    
    redirect_to offline_bookings_path, notice: '已取消预约'
  end

  private
  
  def check_offline_booking_eligible
    unless current_user.offline_booking_eligible?
      if current_user.banned_from_booking?
        redirect_to offline_bookings_path, alert: '您因当年爽约3次已被禁止预约，次年自动恢复'
      else
        redirect_to offline_bookings_path, alert: '您当前没有线下预约资格，请先购买任意课程'
      end
    end
  end
end
