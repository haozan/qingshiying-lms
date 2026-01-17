class MarkdownParserService < ApplicationService
  # 解析Markdown课程目录
  # 目录结构: courses/课程名/章节名/课程.md
  # 
  # 示例:
  #   courses/
  #     01_AI课程/
  #       01_绪论/
  #         01_什么是AI.md
  #         02_AI的应用.md
  #       02_深度学习/
  #         01_神经网络.md
  #
  # Frontmatter格式:
  # ---
  # title: 课程标题
  # free: true
  # video_url: https://qiniu.com/video.mp4
  # ---
  
  COURSES_DIR = Rails.root.join('courses')

  def initialize
    @errors = []
  end

  # 同步所有课程
  def self.sync_all_courses
    new.sync_all_courses
  end

  def sync_all_courses
    return { success: false, error: "课程目录不存在: #{COURSES_DIR}" } unless Dir.exist?(COURSES_DIR)

    Dir.glob(COURSES_DIR.join('*')).select { |f| File.directory?(f) }.sort.each_with_index do |course_dir, index|
      sync_course(course_dir, index)
    end

    { success: true, message: "已同步 #{Course.count} 门课程" }
  rescue => e
    { success: false, error: e.message }
  end

  # 同步单个课程
  def sync_course(course_dir, position = 0)
    course_name = extract_name_from_path(File.basename(course_dir))
    
    # 判断课程类型(从文件夹名称推断)
    course_type = infer_course_type(course_name)
    
    # 使用完整名称作为slug的基础,避免冲突
    slug_base = course_name
    course = Course.find_or_initialize_by(name: course_name)
    course.assign_attributes(
      course_type: course_type,
      position: position,
      status: 'active'
    )
    course.save!

    # 同步章节
    Dir.glob(File.join(course_dir, '*')).select { |f| File.directory?(f) }.sort.each_with_index do |chapter_dir, chapter_index|
      sync_chapter(course, chapter_dir, chapter_index)
    end

    course
  end

  # 同步章节
  def sync_chapter(course, chapter_dir, position = 0)
    chapter_name = extract_name_from_path(File.basename(chapter_dir))
    
    chapter = course.chapters.find_or_initialize_by(slug: chapter_name.parameterize)
    chapter.assign_attributes(
      name: chapter_name,
      position: position
    )
    chapter.save!

    # 同步课节
    Dir.glob(File.join(chapter_dir, '*.md')).sort.each_with_index do |lesson_file, lesson_index|
      sync_lesson(chapter, lesson_file, lesson_index)
    end

    chapter
  end

  # 同步课节
  def sync_lesson(chapter, lesson_file, position = 0)
    content = File.read(lesson_file)
    frontmatter = parse_frontmatter(content)
    
    lesson_name = frontmatter['title'] || extract_name_from_path(File.basename(lesson_file, '.md'))
    
    lesson = chapter.lessons.find_or_initialize_by(slug: lesson_name.parameterize)
    lesson.assign_attributes(
      name: lesson_name,
      content: strip_frontmatter(content),
      video_url: frontmatter['video_url'],
      free: frontmatter['free'] == true || frontmatter['free'] == 'true',
      position: position
    )
    lesson.save!

    lesson
  end

  private

  # 从路径中提取名称(去掉数字前缀)
  # "01_绪论" => "绪论"
  # "02_深度学习基础" => "深度学习基础"
  def extract_name_from_path(path)
    path.sub(/^\d+[_\-]/, '')
  end

  # 推断课程类型
  def infer_course_type(course_name)
    # 写作运营课是买断制,其他是订阅制
    if course_name.include?('写作') || course_name.include?('运营')
      'buyout'
    else
      'subscription'
    end
  end

  # 解析Frontmatter
  def parse_frontmatter(content)
    if content =~ /\A---\s*\n(.*?)\n---\s*\n/m
      yaml_content = $1
      begin
        YAML.safe_load(yaml_content, permitted_classes: [Date, Time]) || {}
      rescue => e
        Rails.logger.error "Frontmatter解析错误: #{e.message}"
        {}
      end
    else
      {}
    end
  end

  # 去掉Frontmatter
  def strip_frontmatter(content)
    content.sub(/\A---\s*\n.*?\n---\s*\n/m, '')
  end
end
