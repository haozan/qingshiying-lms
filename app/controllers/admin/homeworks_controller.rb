class Admin::HomeworksController < Admin::BaseController
  before_action :set_homework, only: [:show, :like, :destroy]

  def index
    @homeworks = Homework.includes(:user, lesson: [:chapter, :course])
                         .order(created_at: :desc)
                         .page(params[:page]).per(20)
    
    # Filter by status
    @homeworks = @homeworks.where(status: params[:status]) if params[:status].present?
    
    # Filter by course
    if params[:course_id].present?
      @homeworks = @homeworks.joins(lesson: :course).where(lessons: { courses: { id: params[:course_id] } })
    end
  end

  def show
  end

  def like
    @homework.like!
    redirect_to admin_homework_path(@homework), notice: '作业已点赞'
  end

  def destroy
    @homework.destroy
    redirect_to admin_homeworks_path, notice: '作业已删除'
  end

  private

  def set_homework
    @homework = Homework.find(params[:id])
  end
end
