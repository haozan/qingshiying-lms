class Admin::CourseBundlesController < Admin::BaseController
  before_action :set_course_bundle, only: [:show, :edit, :update, :destroy]

  def index
    @course_bundles = CourseBundle.page(params[:page]).per(10)
  end

  def show
  end

  def new
    @course_bundle = CourseBundle.new
  end

  def create
    @course_bundle = CourseBundle.new(course_bundle_params)

    if @course_bundle.save
      redirect_to admin_course_bundle_path(@course_bundle), notice: 'Course bundle was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @course_bundle.update(course_bundle_params)
      redirect_to admin_course_bundle_path(@course_bundle), notice: 'Course bundle was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @course_bundle.destroy
    redirect_to admin_course_bundles_path, notice: 'Course bundle was successfully deleted.'
  end

  private

  def set_course_bundle
    @course_bundle = CourseBundle.find(params[:id])
  end

  def course_bundle_params
    params.require(:course_bundle).permit(:name, :description, :original_price, :current_price, :early_bird_price, :status)
  end
end
