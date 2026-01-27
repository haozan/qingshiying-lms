class AddThreeTierPricingToCourses < ActiveRecord::Migration[7.2]
  def change
    add_column :courses, :original_price, :decimal, precision: 10, scale: 2
    add_column :courses, :current_price, :decimal, precision: 10, scale: 2
    add_column :courses, :early_bird_price, :decimal, precision: 10, scale: 2
  end
end
