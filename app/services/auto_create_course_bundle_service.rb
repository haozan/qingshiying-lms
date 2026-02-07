class AutoCreateCourseBundleService < ApplicationService
  def call
    # Get all courses
    ai_course = Course.find_by(name: "AI课程")
    writing_course = Course.find_by(name: "写作运营课")
    programming_course = Course.find_by(name: "AI编程课")

    # Validate courses exist
    unless ai_course && writing_course && programming_course
      missing_courses = []
      missing_courses << "AI课程" unless ai_course
      missing_courses << "写作运营课" unless writing_course
      missing_courses << "AI编程课" unless programming_course
      
      return {
        success: false,
        message: "❌ 缺少课程：#{missing_courses.join(', ')}。请先创建这些课程。"
      }
    end

    # Create or update bundle
    bundle = CourseBundle.find_or_initialize_by(name: "3 课联报特惠")
    bundle.assign_attributes(
      description: "一次性购买所有课程，享受超值优惠！包含：AI课程、写作运营课、AI编程课",
      original_price: 30000.00,
      current_price: 15000.00,
      early_bird_price: 9000.00,
      status: 'active'
    )

    unless bundle.save
      return {
        success: false,
        message: "❌ 套餐保存失败：#{bundle.errors.full_messages.join(', ')}"
      }
    end

    # Clear existing associations
    bundle.course_bundle_items.destroy_all

    # Add courses to bundle
    courses = [ai_course, writing_course, programming_course]
    courses.each_with_index do |course, index|
      bundle.course_bundle_items.create!(
        course: course,
        position: index + 1
      )
    end

    {
      success: true,
      message: "✅ 套餐创建成功！「#{bundle.name}」包含 #{bundle.courses.count} 门课程：#{bundle.courses.pluck(:name).join('、')}"
    }
  rescue => e
    {
      success: false,
      message: "❌ 创建失败：#{e.message}"
    }
  end
end
