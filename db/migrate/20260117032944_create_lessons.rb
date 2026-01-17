class CreateLessons < ActiveRecord::Migration[7.2]
  def change
    create_table :lessons do |t|
      t.references :chapter
      t.string :name
      t.string :slug
      t.text :content
      t.string :video_url
      t.boolean :free, default: false
      t.integer :position, default: 0


      t.timestamps
    end
  end
end
