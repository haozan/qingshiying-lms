class ProgressesController < ApplicationController
  before_action :authenticate_user!

  def dashboard
    @subscriptions = current_user.subscriptions.includes(:course).active
    
    # 学习进度统计
    @progress_stats = @subscriptions.map do |subscription|
      course = subscription.course
      total_lessons = course.lessons.count
      # Lesson通过chapter关联到course，需要join chapters表
      completed_lessons = current_user.progresses
                                       .joins(lesson: :chapter)
                                       .where(chapters: { course_id: course.id })
                                       .completed
                                       .count
      
      {
        course: course,
        subscription: subscription,
        total_lessons: total_lessons,
        completed_lessons: completed_lessons,
        completion_rate: total_lessons > 0 ? (completed_lessons.to_f / total_lessons * 100).round : 0
      }
    end
    
    # 最近提交的作业
    @recent_homeworks = current_user.homeworks.includes(lesson: [:course, :chapter])
                                    .order(created_at: :desc)
                                    .limit(5)
    
    # 被点赞的作业
    @liked_homeworks = current_user.homeworks.liked.includes(lesson: [:course, :chapter])
                                   .order(liked_at: :desc)
                                   .limit(10)
  end

  private
  # Write your private methods here
end
