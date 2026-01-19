class AddFieldsToOfflineSchedules < ActiveRecord::Migration[7.2]
  def change
    add_column :offline_schedules, :current_attendees, :integer, default: 0, null: false
  end
end
