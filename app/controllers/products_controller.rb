class ProductsController < ApplicationController
  def index
    # 按上线时间排序（越早越靠前），未上线的排在最后
    @products = Product.order(Arel.sql('CASE WHEN launch_date IS NULL THEN 1 ELSE 0 END, launch_date ASC'))
  end
end
