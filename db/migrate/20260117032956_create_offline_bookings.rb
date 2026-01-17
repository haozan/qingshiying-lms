class CreateOfflineBookings < ActiveRecord::Migration[7.2]
  def change
    create_table :offline_bookings do |t|
      t.references :user
      t.references :offline_schedule
      t.string :status, default: "confirmed"
      t.datetime :booked_at


      t.timestamps
    end
  end
end
