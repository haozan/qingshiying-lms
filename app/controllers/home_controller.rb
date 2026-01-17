class HomeController < ApplicationController
  include HomeDemoConcern

  def index
    # 允许所有用户（包括已登录用户）访问首页
  end
end
