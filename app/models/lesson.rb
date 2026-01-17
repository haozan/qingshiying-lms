class Lesson < ApplicationRecord
  extend FriendlyId
  friendly_id :slug_candidates, use: :slugged

  # Associations
  belongs_to :chapter
  has_one :course, through: :chapter
  has_many :progresses, dependent: :destroy
  has_many :homeworks, dependent: :destroy

  # Validations
  validates :name, presence: true
  validates :position, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  # Scopes
  scope :ordered, -> { order(position: :asc, created_at: :asc) }
  scope :free_lessons, -> { where(free: true) }

  # 生成slug候选
  def slug_candidates
    [
      :romanized_name,
      [:romanized_name, :id]
    ]
  end

  # 将中文转为拼音，如果失败则使用ID
  def romanized_name
    # 保留英文和数字，将中文转为拼音
    result = name.dup
    
    # 常用词汇映射
    mappings = {
      '写作' => 'xiezuo',
      '基础' => 'jichu',
      '应用' => 'yingyong',
      '编程' => 'biancheng',
      '运营' => 'yunying',
      '高级' => 'gaoji',
      '实战' => 'shizhan',
      '进阶' => 'jinjie',
      '的' => '-'  # 的 -> -
    }
    
    mappings.each do |chinese, pinyin|
      result.gsub!(chinese, pinyin)
    end
    
    # 如果还有中文字符，使用ID
    if result =~ /[\u4e00-\u9fa5]/
      return "lesson-#{id}" if persisted?
      return "lesson-#{SecureRandom.hex(4)}"
    end
    
    result.parameterize
  end

  # 是否有视频
  def has_video?
    video_url.present?
  end

  # 用户是否完成该课
  def completed_by?(user)
    progresses.exists?(user: user, status: 'completed')
  end

  # 用户是否提交作业
  def homework_submitted_by?(user)
    homeworks.exists?(user: user)
  end
end
