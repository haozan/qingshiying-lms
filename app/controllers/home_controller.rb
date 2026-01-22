class HomeController < ApplicationController
  include HomeDemoConcern

  def index
    # 允许所有用户（包括已登录用户）访问首页
    @page_description = "在青狮营 2.0，学习 AI 时代的实战技能。专注法律行业，教你用 AI 工具提效 10 倍，甚至自己构建专属 AI 工具，完成职业生涯的基因重组。"
  end
end
