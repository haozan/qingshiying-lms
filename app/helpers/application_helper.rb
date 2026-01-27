module ApplicationHelper
  # Define your helper methods here
  # 课程图标
  def course_icon(course)
    case course.name
    when /黄金人脉/
      'users'  # 人脉关系图标
    when /AI.*编程/
      'code'
    when /写作.*运营/
      'pen-tool'
    when /AI/
      'brain'
    else
      'book-open'
    end
  end

  # 课程渐变色
  def course_gradient_class(course)
    case course.name
    when /黄金人脉/
      'from-yellow-700 to-amber-800'  # 深黄金色，确保白色文字可读
    when /AI.*编程/
      'from-emerald-700 to-teal-800'
    when /写作.*运营/
      'from-rose-700 to-purple-800'
    when /AI/
      'from-primary to-secondary'
    else
      'from-primary to-primary-light'
    end
  end

  # 课程工具
  def course_tool(course)
    case course.name
    when /黄金人脉/
      { name: '人脉高手 APP', self_developed: true }
    when /AI.*编程/
      { name: 'Clacky.ai', self_developed: false }
    when /写作.*运营/
      { name: '最小阻力写作 APP', self_developed: true }
    when /AI/
      { name: '世界一流大模型', self_developed: false }
    else
      nil
    end
  end

  # 课程价格颜色
  def course_price_color(course)
    'text-accent'  # 所有课程统一使用点缀色黄色
  end

  # 格式化课程价格显示
  def format_course_price(course)
    if course.free?
      '免费'
    elsif course.early_bird_price.present?
      "¥#{sprintf('%.0f', course.early_bird_price)}"
    else
      "¥#{sprintf('%.0f', course.annual_price)}"
    end
  end

  # 渲染Markdown内容
  def render_markdown(content)
    return "" if content.blank?
    Kramdown::Document.new(content).to_html
  end
end
