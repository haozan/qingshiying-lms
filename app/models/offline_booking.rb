class OfflineBooking < ApplicationRecord
  belongs_to :user
  belongs_to :offline_schedule

  # Validations
  validates :status, presence: true, inclusion: { in: %w[confirmed cancelled no_show] }
  validates :user_id, uniqueness: { 
    scope: :offline_schedule_id, 
    conditions: -> { where(status: 'confirmed') },
    message: '已预约该场次' 
  }

  # Scopes
  scope :confirmed, -> { where(status: 'confirmed') }
  scope :no_show, -> { where(status: 'no_show') }

  # 取消预约（带48小时检查）
  def cancel!
    update!(status: 'cancelled')
  end
  
  # 检查是否可以取消（提前48小时）
  def can_cancel?
    return false if status != 'confirmed'
    time_until_schedule = offline_schedule.schedule_date.to_time.beginning_of_day - Time.current
    time_until_schedule >= 48.hours
  end
  
  # 标记为爽约
  def mark_no_show!
    update!(status: 'no_show')
  end
end
