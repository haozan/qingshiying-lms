class Course < ApplicationRecord
  extend FriendlyId
  friendly_id :slug_candidates, use: :slugged

  # Associations
  has_many :chapters, -> { order(position: :asc) }, dependent: :destroy
  has_many :lessons, through: :chapters
  has_many :subscriptions, dependent: :destroy
  has_many :users, through: :subscriptions
  has_many :offline_schedules, dependent: :destroy

  # Validations
  validates :name, presence: true
  validates :status, presence: true, inclusion: { in: %w[active inactive] }
  validates :position, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  # Scopes
  scope :active, -> { where(status: 'active') }
  scope :ordered, -> { order(position: :asc, created_at: :asc) }

  # 生成slug候选
  def slug_candidates
    [
      :romanized_name,
      [:romanized_name, :id]
    ]
  end

  # 将中文转为拼音
  def romanized_name
    result = name.dup
    
    mappings = {
      '课程' => 'kecheng',
      '写作' => 'xiezuo',
      '运营' => 'yunying',
      '编程' => 'biancheng',
      '的' => '-',
      '章节' => 'zhangjie'
    }
    
    mappings.each { |chinese, pinyin| result.gsub!(chinese, pinyin) }
    
    if result =~ /[\u4e00-\u9fa5]/
      return "course-#{id}" if persisted?
      return "course-#{SecureRandom.hex(4)}"
    end
    
    result.parameterize
  end

  # 课程类型（已统一为永久内容+一年线下，保留方法以兼容旧代码）
  def subscription?
    true  # 所有课程统一模式
  end

  def buyout?
    false  # 不再使用买断模式
  end

  # 是否支持线下课(仅AI编程课)
  def has_offline_class?
    name.include?('AI 编程课') || name.include?('编程')
  end
end
