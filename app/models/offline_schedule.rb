class OfflineSchedule < ApplicationRecord
  belongs_to :course, optional: true
  has_many :offline_bookings, dependent: :destroy

  # Validations
  validates :schedule_date, presence: true
  validates :schedule_time, presence: true
  validates :location, presence: true
  validates :status, presence: true, inclusion: { in: %w[available full cancelled] }
  validates :max_attendees, numericality: { only_integer: true, greater_than: 0 }

  # Scopes
  scope :available, -> { where(status: 'available').where('schedule_date >= ?', Date.today) }
  scope :upcoming, -> { where('schedule_date >= ?', Date.today).order(schedule_date: :asc) }

  # 当前预约人数
  def current_attendees
    offline_bookings.where(status: 'confirmed').count
  end

  # 是否已满
  def full?
    current_attendees >= max_attendees
  end

  # 是否可预约
  def bookable?
    status == 'available' && !full? && schedule_date >= Date.today
  end
end
