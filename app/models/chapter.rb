class Chapter < ApplicationRecord
  extend FriendlyId
  friendly_id :slug_candidates, use: :slugged

  # Associations
  belongs_to :course
  has_many :lessons, -> { order(position: :asc) }, dependent: :destroy

  # Validations
  validates :name, presence: true
  validates :position, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  # Scopes
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
      '章节' => 'zhangjie',
      '绪论' => 'xulun',
      '入门' => 'rumen',
      '基础' => 'jichu',
      '应用' => 'yingyong',
      '高级' => 'gaoji',
      '实战' => 'shizhan',
      '进阶' => 'jinjie',
      '构建' => 'goujian',
      '部署' => 'bushu',
      '增长' => 'zengzhang',
      '大模型' => 'damoxing',
      '供应商' => 'gongyingshang',
      '提示词' => 'tishici',
      '的' => '-'
    }
    
    mappings.each { |chinese, pinyin| result.gsub!(chinese, pinyin) }
    
    if result =~ /[\u4e00-\u9fa5]/
      return "chapter-#{id}" if persisted?
      return "chapter-#{SecureRandom.hex(4)}"
    end
    
    result.parameterize
  end
end
