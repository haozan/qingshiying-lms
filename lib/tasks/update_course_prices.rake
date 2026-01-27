namespace :courses do
  desc "Update course prices to three-tier pricing system (one-time update for production)"
  task update_prices: :environment do
    puts "🔄 Updating course prices to three-tier pricing system..."
    
    # AI课程
    ai_course = Course.find_by(slug: "aikecheng")
    if ai_course
      ai_course.update!(
        original_price: 3999.00,
        current_price: 2999.00,
        early_bird_price: 1999.00,
        annual_price: 1999.00
      )
      puts "✅ AI课程 - 原价: ¥3999, 现价: ¥2999, 早鸟价: ¥1999"
    else
      puts "⚠️  AI课程 not found"
    end
    
    # 写作运营课
    writing_course = Course.find_by(slug: "xiezuoyunyingke")
    if writing_course
      writing_course.update!(
        original_price: 5999.00,
        current_price: 3999.00,
        early_bird_price: 2999.00,
        buyout_price: 2999.00
      )
      puts "✅ 写作运营课 - 原价: ¥5999, 现价: ¥3999, 早鸟价: ¥2999"
    else
      puts "⚠️  写作运营课 not found"
    end
    
    # AI编程课
    programming_course = Course.find_by(slug: "aibianchengke")
    if programming_course
      programming_course.update!(
        original_price: 19999.00,
        current_price: 7999.00,
        early_bird_price: 6999.00,
        annual_price: 6999.00
      )
      puts "✅ AI编程课 - 原价: ¥19999, 现价: ¥7999, 早鸟价: ¥6999"
    else
      puts "⚠️  AI编程课 not found"
    end
    
    puts "🎉 Price update completed!"
  end
end
