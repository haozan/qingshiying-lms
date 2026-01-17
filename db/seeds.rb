# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# IMPORTANT: Do NOT add Administrator data here!
# Administrator accounts should be created manually by user.
# This seeds file is only for application data (products, categories, etc.)
#
require 'open-uri'

# Write your seed data here

puts "🌱 Starting seed data..."

# 清理旧数据
puts "Cleaning old data..."
Homework.destroy_all
Progress.destroy_all
Subscription.destroy_all
Lesson.destroy_all
Chapter.destroy_all
Course.destroy_all

# 创建课程
puts "Creating courses..."

# AI课程（订阅制）
ai_course = Course.create!(
  name: "AI课程",
  slug: "aikecheng",
  description: "全面掌握人工智能基础知识和实际应用",
  course_type: "subscription",
  annual_price: 999.00,
  status: "active",
  position: 1
)

# 写作运营课（买断制）
writing_course = Course.create!(
  name: "写作运营课",
  slug: "xiezuoyunyingke",
  description: "从零开始学习内容创作和运营技巧",
  course_type: "buyout",
  buyout_price: 299.00,
  status: "active",
  position: 2
)

# AI编程课（订阅制）
programming_course = Course.create!(
  name: "AI编程课",
  slug: "aibianchengke",
  description: "用AI提升编程效率，掌握现代开发技能",
  course_type: "subscription",
  annual_price: 1299.00,
  status: "active",
  position: 3
)

puts "Creating chapters and lessons..."

# AI课程 - 绪论章节
ai_chapter1 = ai_course.chapters.create!(
  name: "绪论",
  slug: "xulun",
  position: 1
)

ai_chapter1.lessons.create!([
  {
    name: "什么是AI",
    slug: "shenmeshiai",
    content: File.read(Rails.root.join("courses/01_AI课程/01_绪论/01_什么是AI.md")),
    free: true,
    position: 1
  },
  {
    name: "AI的应用",
    slug: "ai-yingyong",
    content: File.read(Rails.root.join("courses/01_AI课程/01_绪论/02_AI的应用.md")),
    free: false,
    position: 2
  }
])

# 写作运营课 - 基础章节
writing_chapter1 = writing_course.chapters.create!(
  name: "基础",
  slug: "jichu",
  position: 1
)

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

# 写作运营课 - 进阶章节
writing_chapter2 = writing_course.chapters.create!(
  name: "进阶",
  slug: "jinjie",
  position: 2
)

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

# 写作运营课 - 实战章节
writing_chapter3 = writing_course.chapters.create!(
  name: "实战",
  slug: "shizhan",
  position: 3
)

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

# 写作运营课 - 高级章节
writing_chapter4 = writing_course.chapters.create!(
  name: "高级",
  slug: "gaoji",
  position: 4
)

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

# AI编程课 - 入门章节
programming_chapter1 = programming_course.chapters.create!(
  name: "入门",
  slug: "rumen",
  position: 1
)

programming_chapter1.lessons.create!([
  {
    name: "Python基础",
    slug: "python-jichu",
    content: File.read(Rails.root.join("courses/03_AI编程课/01_入门/01_Python基础.md")),
    free: true,
    position: 1
  }
])

puts "✅ Seed data created successfully!"
puts "📊 Summary:"
puts "  - Courses: #{Course.count}"
puts "  - Chapters: #{Chapter.count}"
puts "  - Lessons: #{Lesson.count}"
puts "  - Writing course lessons: #{writing_course.chapters.includes(:lessons).map(&:lessons).flatten.count}"
