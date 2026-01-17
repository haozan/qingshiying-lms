class LessonsController < ApplicationController
  before_action :authenticate_user!
  before_action :find_lesson
  before_action :check_access!

  def show
    @full_render = true  # 隐藏导航栏，让学习页面占据全屏
    @course = @lesson.chapter.course
    @chapter = @lesson.chapter
    @chapters = @course.chapters.ordered.includes(:lessons)
    
    # 获取或创建进度记录
    @progress = current_user.progresses.find_or_create_by(lesson: @lesson)
    @progress.update(status: 'in_progress') if @progress.status == 'pending'
    
    # 获取作业(如果有)
    @homework = current_user.homeworks.find_by(lesson: @lesson)
    
    # 获取当前课节的上一节和下一节
    @prev_lesson = find_prev_lesson
    @next_lesson = find_next_lesson
  end

  # 提交作业(Turbo Stream)
  def submit_homework
    @lesson = Lesson.friendly.find(params[:id])
    @homework = current_user.homeworks.find_or_initialize_by(lesson: @lesson)
    @homework.content = params[:homework_content]
    @homework.status = 'submitted'
    
    if @homework.save
      # 标记课程为已完成
      @progress = current_user.progresses.find_by(lesson: @lesson)
      @progress&.mark_as_completed!
      
      render :submit_homework
    else
      redirect_to lesson_path(@lesson), alert: '作业提交失败'
    end
  end

  private

  def find_lesson
    @lesson = Lesson.friendly.find(params[:id])
  end

  def check_access!
    course = @lesson.chapter.course
    
    # 免费课程可以访问
    return if @lesson.free?
    
    # 检查用户是否有课程权限
    unless current_user.has_access_to?(course)
      redirect_to courses_path, alert: '请先订阅该课程'
    end
  end

  def find_prev_lesson
    # 同一章节的上一节
    prev_in_chapter = @chapter.lessons.where('position < ?', @lesson.position).order(position: :desc).first
    return prev_in_chapter if prev_in_chapter
    
    # 上一章节的最后一节
    prev_chapter = @course.chapters.where('position < ?', @chapter.position).order(position: :desc).first
    prev_chapter&.lessons&.last
  end

  def find_next_lesson
    # 同一章节的下一节
    next_in_chapter = @chapter.lessons.where('position > ?', @lesson.position).order(position: :asc).first
    return next_in_chapter if next_in_chapter
    
    # 下一章节的第一节
    next_chapter = @course.chapters.where('position > ?', @chapter.position).order(position: :asc).first
    next_chapter&.lessons&.first
  end
end
