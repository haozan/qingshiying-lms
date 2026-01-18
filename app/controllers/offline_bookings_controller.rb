class OfflineBookingsController < ApplicationController
  before_action :authenticate_user!, except: [:index]
  before_action :check_offline_booking_eligible, only: [:create]

  def index
    @schedules = OfflineSchedule.available.includes(:course, :offline_bookings).order(schedule_date: :asc, schedule_time: :asc)
    
    if current_user
      @my_bookings = current_user.offline_bookings.confirmed.includes(offline_schedule: [:course]).order(created_at: :desc)
      @eligible = current_user.offline_booking_eligible?
      @expires_at = current_user.offline_booking_expires_at
    else
      @my_bookings = []
      @eligible = false
      @expires_at = nil
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
      if @schedule.full?
        @schedule.update!(status: 'full')
      end
      redirect_to offline_bookings_path, notice: '预约成功'
    else
      redirect_to offline_bookings_path, alert: @booking.errors.full_messages.join(', ')
    end
  end

  def destroy
    @booking = current_user.offline_bookings.find(params[:id])
    @schedule = @booking.offline_schedule
    
    @booking.cancel!
    
    if @schedule.status == 'full' && !@schedule.full?
      @schedule.update!(status: 'available')
    end
    
    redirect_to offline_bookings_path, notice: '已取消预约'
  end

  private
  
  def check_offline_booking_eligible
    unless current_user.offline_booking_eligible?
      redirect_to offline_bookings_path, alert: '您当前没有线下预约资格，请先购买任意课程'
    end
  end
end
