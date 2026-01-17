class CreateChapters < ActiveRecord::Migration[7.2]
  def change
    create_table :chapters do |t|
      t.references :course
      t.string :name
      t.string :slug
      t.text :description
      t.integer :position, default: 0


      t.timestamps
    end
  end
end
