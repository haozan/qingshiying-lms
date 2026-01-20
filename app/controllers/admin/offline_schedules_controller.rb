class Admin::OfflineSchedulesController < Admin::BaseController
  before_action :set_offline_schedule, only: [:show, :edit, :update, :destroy]

  def index
    @offline_schedules = OfflineSchedule.page(params[:page]).per(10)
  end

  def show
  end

  def new
    @offline_schedule = OfflineSchedule.new
  end

  def create
    @offline_schedule = OfflineSchedule.new(offline_schedule_params)

    if @offline_schedule.save
      redirect_to admin_offline_schedule_path(@offline_schedule), notice: '线下日程创建成功'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @offline_schedule.update(offline_schedule_params)
      redirect_to admin_offline_schedule_path(@offline_schedule), notice: '线下日程更新成功'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @offline_schedule.destroy
    redirect_to admin_offline_schedules_path, notice: '线下日程删除成功'
  end

  private

  def set_offline_schedule
    @offline_schedule = OfflineSchedule.find(params[:id])
  end

  def offline_schedule_params
    params.require(:offline_schedule).permit(:schedule_date, :schedule_time, :location, :max_attendees, :status)
  end
end
