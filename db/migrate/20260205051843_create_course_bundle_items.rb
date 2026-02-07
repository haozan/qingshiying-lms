class CreateCourseBundleItems < ActiveRecord::Migration[7.2]
  def change
    create_table :course_bundle_items do |t|
      t.references :course_bundle
      t.references :course
      t.integer :position, default: 0


      t.timestamps
    end
  end
end
