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



  # 是否为免费课程
  def free?
    annual_price.to_f.zero?
  end

  # 是否支持线下课(仅AI编程课)
  def has_offline_class?
    name.include?('AI 编程课') || name.include?('编程')
  end

  # Stripe 支付集成方法
  # 返回 Stripe 支付线条目
  def stripe_line_items
    price = early_bird_price.presence || current_price.presence || annual_price
    [
      {
        price_data: {
          currency: 'cny',
          product_data: {
            name: name,
            description: description.presence || "青狮营课程"
          },
          unit_amount: (price * 100).to_i
        },
        quantity: 1
      }
    ]
  end

  # 支付模式：一次性支付
  def stripe_mode
    'payment'
  end

  # 客户信息（Payment 模型会优先使用 user 信息）
  def customer_name
    "青狮营学员"
  end

  def customer_email
    # Payment 模型会使用 user.email
    nil
  end

  # 支付描述
  def payment_description
    "青狮营 - #{name}"
  end
end
