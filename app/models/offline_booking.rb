class OfflineBooking < ApplicationRecord
  belongs_to :user
  belongs_to :offline_schedule

  # Validations
  validates :status, presence: true, inclusion: { in: %w[confirmed cancelled no_show] }
  validates :user_id, uniqueness: { scope: :offline_schedule_id, message: '已预约该场次' }

  # Scopes
  scope :confirmed, -> { where(status: 'confirmed') }
  scope :no_show, -> { where(status: 'no_show') }

  # 取消预约
  def cancel!
    update!(status: 'cancelled')
  end
  
  # 标记为爽约
  def mark_no_show!
    update!(status: 'no_show')
  end
end
