class Admin::OfflineBookingsController < Admin::BaseController
  before_action :set_offline_booking, only: [:show, :edit, :update, :destroy, :mark_no_show]

  def index
    @offline_bookings = OfflineBooking.includes(:user, :offline_schedule)
                                       .order(created_at: :desc)
                                       .page(params[:page]).per(20)
  end

  def show
  end

  def new
    @offline_booking = OfflineBooking.new
  end

  def create
    @offline_booking = OfflineBooking.new(offline_booking_params)

    if @offline_booking.save
      redirect_to admin_offline_booking_path(@offline_booking), notice: '线下预约创建成功'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @offline_booking.update(offline_booking_params)
      redirect_to admin_offline_booking_path(@offline_booking), notice: '线下预约更新成功'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @offline_booking.destroy
    redirect_to admin_offline_bookings_path, notice: '线下预约删除成功'
  end
  
  # 标记为爽约
  def mark_no_show
    if @offline_booking.status == 'confirmed' && @offline_booking.mark_no_show!
      redirect_to admin_offline_bookings_path, notice: "已标记为爽约"
    else
      redirect_to admin_offline_bookings_path, alert: "标记失败：只能标记已确认的预约"
    end
  end

  private

  def set_offline_booking
    @offline_booking = OfflineBooking.find(params[:id])
  end

  def offline_booking_params
    params.require(:offline_booking).permit(:status, :booked_at, :user_id, :offline_schedule_id)
  end
end
