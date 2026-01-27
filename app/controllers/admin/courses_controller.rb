class Admin::CoursesController < Admin::BaseController
  before_action :set_course, only: [:show, :edit, :update, :destroy]

  def index
    @courses = Course.page(params[:page]).per(10)
  end

  def show
  end

  def new
    @course = Course.new
  end

  def create
    @course = Course.new(course_params)

    if @course.save
      redirect_to admin_course_path(@course), notice: 'Course was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @course.update(course_params)
      redirect_to admin_course_path(@course), notice: 'Course was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @course.destroy
    redirect_to admin_courses_path, notice: 'Course was successfully deleted.'
  end

  private

  def set_course
    @course = Course.find(params[:id])
  end

  def course_params
    params.require(:course).permit(:name, :slug, :description, :status, :position, :annual_price, :original_price, :current_price, :early_bird_price)
  end
end
