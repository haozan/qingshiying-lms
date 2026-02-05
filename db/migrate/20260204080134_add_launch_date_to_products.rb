class AddLaunchDateToProducts < ActiveRecord::Migration[7.2]
  def change
    add_column :products, :launch_date, :date

  end
end
