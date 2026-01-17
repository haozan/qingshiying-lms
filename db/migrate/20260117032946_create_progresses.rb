class CreateProgresses < ActiveRecord::Migration[7.2]
  def change
    create_table :progresses do |t|
      t.references :user
      t.references :lesson
      t.datetime :completed_at
      t.string :status, default: "pending"


      t.timestamps
    end
  end
end
