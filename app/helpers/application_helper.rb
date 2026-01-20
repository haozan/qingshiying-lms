module ApplicationHelper
  # Define your helper methods here
  # 课程图标
  def course_icon(course)
    case course.name
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

  # 渲染Markdown内容
  def render_markdown(content)
    return "" if content.blank?
    Kramdown::Document.new(content).to_html
  end
end
