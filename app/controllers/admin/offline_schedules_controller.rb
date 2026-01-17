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
      redirect_to admin_offline_schedule_path(@offline_schedule), notice: 'Offline schedule was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @offline_schedule.update(offline_schedule_params)
      redirect_to admin_offline_schedule_path(@offline_schedule), notice: 'Offline schedule was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @offline_schedule.destroy
    redirect_to admin_offline_schedules_path, notice: 'Offline schedule was successfully deleted.'
  end

  private

  def set_offline_schedule
    @offline_schedule = OfflineSchedule.find(params[:id])
  end

  def offline_schedule_params
    params.require(:offline_schedule).permit(:schedule_date, :max_attendees, :status, :course_id)
  end
end
