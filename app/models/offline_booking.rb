class OfflineBooking < ApplicationRecord
  belongs_to :user
  belongs_to :offline_schedule

  # Validations
  validates :status, presence: true, inclusion: { in: %w[confirmed cancelled] }
  validates :user_id, uniqueness: { scope: :offline_schedule_id, message: '已预约该场次' }

  # Scopes
  scope :confirmed, -> { where(status: 'confirmed') }

  # 取消预约
  def cancel!
    update!(status: 'cancelled')
  end
end
