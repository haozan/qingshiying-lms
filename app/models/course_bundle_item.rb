class CourseBundleItem < ApplicationRecord
  belongs_to :course_bundle
  belongs_to :course

  # Validations
  validates :course_id, uniqueness: { scope: :course_bundle_id, message: "已经在套餐中" }
  validates :position, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
end
