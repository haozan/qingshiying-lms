class AddPricesToCourses < ActiveRecord::Migration[7.2]
  def change
    add_column :courses, :annual_price, :decimal, precision: 10, scale: 2, default: 999.00
    add_column :courses, :buyout_price, :decimal, precision: 10, scale: 2, default: 2999.00

  end
end
