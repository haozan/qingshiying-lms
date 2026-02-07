# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# IMPORTANT: Do NOT add Administrator data here!
# Administrator accounts should be created manually by user.
# This seeds file is only for application data (products, categories, etc.)
#
require 'open-uri'

# Write your seed data here

puts "🌱 Starting seed data..."

# ⚠️ 只在开发和测试环境清理旧数据
# 生产环境保留现有数据，使用 find_or_create_by 确保不覆盖已修改的价格
if Rails.env.development? || Rails.env.test?
  puts "Cleaning old data (#{Rails.env} environment)..."
  Homework.destroy_all
  Progress.destroy_all
  Subscription.destroy_all
  Lesson.destroy_all
  Chapter.destroy_all
  Course.destroy_all
end

# 创建课程 - 使用 find_or_create_by 避免覆盖生产环境的价格修改
puts "Creating courses..."

# AI课程（订阅制）
ai_course = Course.find_or_create_by!(slug: "aikecheng") do |course|
  course.name = "AI课程"
  course.description = "全面掌握人工智能基础知识和实际应用"

  course.original_price = 3999.00
  course.current_price = 2999.00
  course.early_bird_price = 1999.00
  course.annual_price = 1999.00  # 默认使用早鸟价
  course.status = "active"
  course.position = 1
end

# 写作运营课（买断制）
writing_course = Course.find_or_create_by!(slug: "xiezuoyunyingke") do |course|
  course.name = "写作运营课"
  course.description = "从零开始学习内容创作和运营技巧"

  course.original_price = 5999.00
  course.current_price = 3999.00
  course.early_bird_price = 2999.00

  course.status = "active"
  course.position = 2
end

# AI编程课（订阅制）
programming_course = Course.find_or_create_by!(slug: "aibianchengke") do |course|
  course.name = "AI编程课"
  course.description = "用AI提升编程效率，掌握现代开发技能"

  course.original_price = 19999.00
  course.current_price = 7999.00
  course.early_bird_price = 6999.00
  course.annual_price = 6999.00  # 默认使用早鸟价
  course.status = "active"
  course.position = 3
end

puts "Creating chapters and lessons..."

# AI课程 - 基础章节
ai_chapter1 = ai_course.chapters.find_or_create_by!(slug: "jichu") do |chapter|
  chapter.name = "基础"
  chapter.position = 1
end

# AI课程 - 大模型章节
ai_chapter2 = ai_course.chapters.find_or_create_by!(slug: "damoxing") do |chapter|
  chapter.name = "大模型"
  chapter.position = 2
end

# AI课程 - 供应商章节
ai_chapter3 = ai_course.chapters.find_or_create_by!(slug: "gongyingshang") do |chapter|
  chapter.name = "供应商"
  chapter.position = 3
end

# AI课程 - 提示词章节
ai_chapter4 = ai_course.chapters.find_or_create_by!(slug: "tishici") do |chapter|
  chapter.name = "提示词"
  chapter.position = 4
end

# AI课程 - 实战章节
ai_chapter5 = ai_course.chapters.find_or_create_by!(slug: "shizhan") do |chapter|
  chapter.name = "实战"
  chapter.position = 5
end

# 写作运营课 - 基础章节
writing_chapter1 = writing_course.chapters.find_or_create_by!(slug: "jichu") do |chapter|
  chapter.name = "基础"
  chapter.position = 1
end

if writing_chapter1.lessons.empty?
  writing_chapter1.lessons.create!([
    {
      name: "写作基础",
      slug: "xiezuojichu",
      content: File.read(Rails.root.join("courses/02_写作运营课/01_基础/01_写作基础.md")),
      free: true,
      position: 1
    },
    {
      name: "内容定位",
      slug: "neirongdingwei",
      content: File.read(Rails.root.join("courses/02_写作运营课/01_基础/02_内容定位.md")),
      free: false,
      position: 2
    },
    {
      name: "标题技巧",
      slug: "biaotijiqiao",
      content: File.read(Rails.root.join("courses/02_写作运营课/01_基础/03_标题技巧.md")),
      free: false,
      position: 3
    }
  ])
end

# 写作运营课 - 进阶章节
writing_chapter2 = writing_course.chapters.find_or_create_by!(slug: "jinjie") do |chapter|
  chapter.name = "进阶"
  chapter.position = 2
end

if writing_chapter2.lessons.empty?
  writing_chapter2.lessons.create!([
    {
      name: "选题策划",
      slug: "xuanticehua",
      content: File.read(Rails.root.join("courses/02_写作运营课/02_进阶/01_选题策划.md")),
      free: false,
      position: 1
    },
    {
      name: "内容结构",
      slug: "neirongjiegou",
      content: File.read(Rails.root.join("courses/02_写作运营课/02_进阶/02_内容结构.md")),
      free: false,
      position: 2
    },
    {
      name: "文案优化",
      slug: "wenanyouhua",
      content: File.read(Rails.root.join("courses/02_写作运营课/02_进阶/03_文案优化.md")),
      free: false,
      position: 3
    }
  ])
end

# 写作运营课 - 实战章节
writing_chapter3 = writing_course.chapters.find_or_create_by!(slug: "shizhan") do |chapter|
  chapter.name = "实战"
  chapter.position = 3
end

if writing_chapter3.lessons.empty?
  writing_chapter3.lessons.create!([
    {
      name: "平台运营",
      slug: "pingtaiyunying",
      content: File.read(Rails.root.join("courses/02_写作运营课/03_实战/01_平台运营.md")),
      free: false,
      position: 1
    },
    {
      name: "数据分析",
      slug: "shujufenxi",
      content: File.read(Rails.root.join("courses/02_写作运营课/03_实战/02_数据分析.md")),
      free: false,
      position: 2
    },
    {
      name: "变现策略",
      slug: "bianxiancelue",
      content: File.read(Rails.root.join("courses/02_写作运营课/03_实战/03_变现策略.md")),
      free: false,
      position: 3
    }
  ])
end

# 写作运营课 - 高级章节
writing_chapter4 = writing_course.chapters.find_or_create_by!(slug: "gaoji") do |chapter|
  chapter.name = "高级"
  chapter.position = 4
end

if writing_chapter4.lessons.empty?
  writing_chapter4.lessons.create!([
    {
      name: "个人品牌",
      slug: "gerenpinpai",
      content: File.read(Rails.root.join("courses/02_写作运营课/04_高级/01_个人品牌.md")),
      free: false,
      position: 1
    },
    {
      name: "私域运营",
      slug: "siyuyunying",
      content: File.read(Rails.root.join("courses/02_写作运营课/04_高级/02_私域运营.md")),
      free: false,
      position: 2
    }
  ])
end

# AI编程课 - 基础章节
programming_chapter1 = programming_course.chapters.find_or_create_by!(slug: "jichu") do |chapter|
  chapter.name = "基础"
  chapter.position = 1
end

# AI编程课 - 构建章节
programming_chapter2 = programming_course.chapters.find_or_create_by!(slug: "goujian") do |chapter|
  chapter.name = "构建"
  chapter.position = 2
end

# AI编程课 - 部署章节
programming_chapter3 = programming_course.chapters.find_or_create_by!(slug: "bushu") do |chapter|
  chapter.name = "部署"
  chapter.position = 3
end

# AI编程课 - 增长章节
programming_chapter4 = programming_course.chapters.find_or_create_by!(slug: "zengzhang") do |chapter|
  chapter.name = "增长"
  chapter.position = 4
end

puts "✅ Seed data created successfully!"
puts "📊 Summary:"
puts "  - Courses: #{Course.count}"
puts "  - Chapters: #{Chapter.count}"
puts "  - Lessons: #{Lesson.count}"
puts "  - Writing course lessons: #{writing_course.chapters.includes(:lessons).map(&:lessons).flatten.count}"

# 创建 3 课联报套餐
if Rails.env.development? || Rails.env.test?
  puts "\nCreating course bundle..."
  
  bundle = CourseBundle.find_or_create_by!(name: "3 课联报特惠") do |b|
    b.description = "一次性购买所有课程，享受超值优惠！包含：AI课程、写作运营课、AI编程课"
    b.original_price = 30000.00
    b.current_price = 15000.00
    b.early_bird_price = 9000.00
    b.status = 'active'
  end
  
  # 清理现有关联
  bundle.course_bundle_items.destroy_all
  
  # 添加所有课程到套餐
  [ai_course, writing_course, programming_course].each_with_index do |course, index|
    bundle.course_bundle_items.create!(
      course: course,
      position: index + 1
    )
  end
  
  puts "  - Course Bundles: #{CourseBundle.count}"
  puts "  - Bundle includes #{bundle.courses.count} courses: #{bundle.courses.pluck(:name).join(', ')}"
end
