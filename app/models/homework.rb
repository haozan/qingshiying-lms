class Homework < ApplicationRecord
  belongs_to :user
  belongs_to :lesson

  # Validations
  validates :content, presence: true
  validates :status, presence: true, inclusion: { in: %w[submitted reviewed liked] }

  # Scopes
  scope :submitted, -> { where(status: 'submitted') }
  scope :liked, -> { where.not(liked_at: nil) }

  # 导师点赞
  def like!
    update!(liked_at: Time.current, status: 'liked')
  end

  # 是否被点赞
  def liked?
    liked_at.present?
  end
end
