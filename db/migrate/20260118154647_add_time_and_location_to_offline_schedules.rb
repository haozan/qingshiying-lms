class AddTimeAndLocationToOfflineSchedules < ActiveRecord::Migration[7.2]
  def change
    add_column :offline_schedules, :schedule_time, :string
    add_column :offline_schedules, :location, :string

  end
end
