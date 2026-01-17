class Progress < ApplicationRecord
  belongs_to :user
  belongs_to :lesson

  # Validations
  validates :status, presence: true, inclusion: { in: %w[pending in_progress completed] }
  validates :user_id, uniqueness: { scope: :lesson_id }

  # Scopes
  scope :completed, -> { where(status: 'completed') }
  scope :in_progress, -> { where(status: 'in_progress') }

  # 标记为已完成
  def mark_as_completed!
    update!(status: 'completed', completed_at: Time.current)
  end
end
