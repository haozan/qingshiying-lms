class CreateCourseBundles < ActiveRecord::Migration[7.2]
  def change
    create_table :course_bundles do |t|
      t.string :name
      t.text :description
      t.decimal :original_price
      t.decimal :current_price
      t.decimal :early_bird_price
      t.string :status, default: "active"


      t.timestamps
    end
  end
end
