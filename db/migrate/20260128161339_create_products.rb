class CreateProducts < ActiveRecord::Migration[7.2]
  def change
    create_table :products do |t|
      t.string :title
      t.string :subtitle
      t.string :og_url
      t.string :cover_image_url


      t.timestamps
    end
  end
end
