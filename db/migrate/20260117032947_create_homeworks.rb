class CreateHomeworks < ActiveRecord::Migration[7.2]
  def change
    create_table :homeworks do |t|
      t.references :user
      t.references :lesson
      t.text :content
      t.string :status, default: "submitted"
      t.datetime :liked_at


      t.timestamps
    end
  end
end
