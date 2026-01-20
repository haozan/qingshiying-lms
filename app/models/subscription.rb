class Subscription < ApplicationRecord
  belongs_to :user
  belongs_to :course
  has_one :payment, as: :payable, dependent: :destroy

  # Validations
  validates :status, presence: true, inclusion: { in: %w[pending active expired cancelled] }
  validates :payment_type, presence: true, inclusion: { in: %w[annual buyout] }

  # Scopes
  scope :active, -> { where(status: 'active') }
  scope :expired, -> { where(status: 'expired') }

  # 检查是否有效（内容访问永久有效）
  def active?
    status == 'active'
  end
  
  # 检查线下预约资格（购买后一年内）
  # 免费课程不获得线下预约资格
  def offline_eligible?
    return false unless status == 'active'
    return false if course.free?  # 免费课程无线下预约资格
    return false if started_at.nil?
    
    Time.current < (started_at + 1.year)
  end

  # 续费（延长线下预约资格）
  def renew!(days = 365)
    # 续费主要延长线下预约资格，内容访问本来就是永久的
    # 如果已过期或首次购买，从今天开始计算
    self.started_at = Time.current if started_at.nil?
    self.status = 'active'
    save!
  end

  # 自动检查并更新过期状态（内容访问不过期，此方法保留但不再使用）
  def check_expiration!
    # 内容访问永久有效，不需要检查过期
  end

  # ============== Payment Interface (REQUIRED by Payment model) ==============
  # These methods are called by StripePaymentService
  
  def customer_name
    user.email.split('@').first
  end

  def customer_email
    user.email
  end

  def payment_description
    if course.free?
      "#{course.name} - 课程订阅（免费课程）"
    else
      "#{course.name} - 课程订阅（永久内容+一年线下）"
    end
  end

  # Always use 'payment' mode (one-time checkout, not recurring subscription)
  def stripe_mode
    'payment'
  end

  def stripe_line_items
    price = course.annual_price
    
    [{
      price_data: {
        currency: 'cny',
        product_data: { 
          name: course.name,
          description: payment_description
        },
        unit_amount: (price * 100).to_i  # Convert to cents
      },
      quantity: 1
    }]
  end
end
