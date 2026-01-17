namespace :courses do
  desc "同步所有Markdown课程到数据库"
  task sync: :environment do
    puts "开始同步课程..."
    result = MarkdownParserService.sync_all_courses
    
    if result[:success]
      puts "✓ #{result[:message]}"
      puts "\n课程列表:"
      Course.ordered.each do |course|
        puts "  - #{course.name} (#{course.course_type}): #{course.chapters.count} 章, #{course.lessons.count} 节"
      end
    else
      puts "✗ 同步失败: #{result[:error]}"
    end
  end
end
