class CreateCourses < ActiveRecord::Migration[7.2]
  def change
    create_table :courses do |t|
      t.string :name
      t.string :slug
      t.text :description
      t.string :course_type, default: "subscription"
      t.string :status, default: "active"
      t.integer :position, default: 0

      t.index :slug, unique: true

      t.timestamps
    end
  end
end
