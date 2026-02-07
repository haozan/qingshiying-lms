class CreateBundleSubscriptions < ActiveRecord::Migration[7.2]
  def change
    create_table :bundle_subscriptions do |t|
      t.references :user
      t.references :course_bundle
      t.string :status, default: "pending"
      t.datetime :started_at


      t.timestamps
    end
  end
end
