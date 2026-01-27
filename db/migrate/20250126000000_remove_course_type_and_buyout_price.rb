class RemoveCourseTypeAndBuyoutPrice < ActiveRecord::Migration[7.2]
  def change
    remove_column :courses, :course_type, :string
    remove_column :courses, :buyout_price, :decimal
  end
end
