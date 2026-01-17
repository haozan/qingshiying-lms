class OfflineBookingsController < ApplicationController
  before_action :authenticate_user!
  before_action :check_ai_programming_access

  def index
    @bookings = current_user.offline_bookings.includes(offline_schedule: :course).order(created_at: :desc)
    @upcoming_bookings = @bookings.confirmed.joins(:offline_schedule).where('offline_schedules.schedule_date >= ?', Date.today)
  end

  def new
    @schedule = OfflineSchedule.find(params[:schedule_id])
    @booking = current_user.offline_bookings.new(offline_schedule: @schedule)
    
    unless @schedule.bookable?
      redirect_to course_path(@schedule.course), alert: '该场次不可预约'
    end
  end

  def create
    @schedule = OfflineSchedule.find(params[:offline_schedule_id])
    @booking = current_user.offline_bookings.new(
      offline_schedule: @schedule,
      status: 'confirmed'
    )
    
    if @schedule.bookable? && @booking.save
      # 检查是否已满
      if @schedule.full?
        @schedule.update!(status: 'full')
      end
      
      redirect_to offline_bookings_path, notice: '预约成功'
    else
      redirect_to course_path(@schedule.course), alert: '预约失败,该场次可能已满'
    end
  end

  def destroy
    @booking = current_user.offline_bookings.find(params[:id])
    @schedule = @booking.offline_schedule
    
    @booking.cancel!
    
    # 如果之前是满员,现在恢复 available
    if @schedule.status == 'full'
      @schedule.update!(status: 'available')
    end
    
    redirect_to offline_bookings_path, notice: '已取消预约'
  end

  private
  
  def check_ai_programming_access
    # 查找 AI编程课
    ai_programming_course = Course.find_by('name LIKE ?', '%编程%')
    
    unless ai_programming_course && current_user.has_access_to?(ai_programming_course)
      redirect_to courses_path, alert: '仅AI编程课学员可预约线下课'
    end
  end
end
