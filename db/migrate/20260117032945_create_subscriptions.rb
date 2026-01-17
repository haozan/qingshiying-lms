class CreateSubscriptions < ActiveRecord::Migration[7.2]
  def change
    create_table :subscriptions do |t|
      t.references :user
      t.references :course
      t.datetime :started_at
      t.datetime :expires_at
      t.string :status, default: "active"
      t.string :payment_type, default: "annual"


      t.timestamps
    end
  end
end
