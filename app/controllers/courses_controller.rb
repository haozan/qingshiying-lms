class CoursesController < ApplicationController
  before_action :authenticate_user!, except: [:index]

  def index
    @courses = Course.active.ordered
    
    # 获取用户最近学习位置
    @last_position = current_user.last_learning_position if current_user
    
    # 获取用户的订阅信息
    @subscriptions = current_user ? current_user.subscriptions.active.index_by(&:course_id) : {}
  end

  def show
    @course = Course.friendly.find(params[:id])
    @subscription = current_user.subscriptions.find_by(course: @course) if current_user
    @first_lesson = @course.lessons.first
  end

  private
  
  def has_free_lessons?
    @course.lessons.where(free: true).any?
  end
end
