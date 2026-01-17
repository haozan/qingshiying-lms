class LessonsController < ApplicationController
  before_action :authenticate_user!
  before_action :find_lesson
  # 移除 check_access! - 允许用户进入页面查看锁定状态

  def show
    @full_render = true  # 隐藏导航栏，让学习页面占据全屏
    @course = @lesson.chapter.course
    @chapter = @lesson.chapter
    @chapters = @course.chapters.ordered.includes(:lessons)
    
    # 检查用户是否有访问权限
    @has_access = @lesson.free? || current_user.has_access_to?(@course)
    
    # 计算课程进度
    @total_lessons = @course.lessons.count
    @completed_lessons = current_user.progresses.joins(:lesson)
                                      .where(lessons: { chapter_id: @course.chapters.pluck(:id) })
                                      .where(status: 'completed')
                                      .count
    @progress_percentage = @total_lessons > 0 ? (@completed_lessons.to_f / @total_lessons * 100).round : 0
    
    # 只有有权限的用户才创建进度记录
    if @has_access
      # 获取或创建进度记录
      @progress = current_user.progresses.find_or_create_by(lesson: @lesson)
      @progress.update(status: 'in_progress') if @progress.status == 'pending'
      
      # 获取作业(如果有)
      @homework = current_user.homeworks.find_by(lesson: @lesson)
    end
    
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
