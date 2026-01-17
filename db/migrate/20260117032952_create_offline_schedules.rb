class CreateOfflineSchedules < ActiveRecord::Migration[7.2]
  def change
    create_table :offline_schedules do |t|
      t.references :course
      t.date :schedule_date
      t.integer :max_attendees, default: 50
      t.string :status, default: "available"


      t.timestamps
    end
  end
end
