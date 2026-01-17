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

  # 检查是否有效
  def active?
    return false unless status == 'active'
    
    # 买断制永久有效
    return true if payment_type == 'buyout'
    
    # 订阅制检查过期时间
    expires_at.nil? || expires_at > Time.current
  end

  # 续费(顺延叠加)
  def renew!(days = 365)
    if expires_at.nil? || expires_at < Time.current
      # 如果已过期或首次购买,从今天开始计算
      self.expires_at = Time.current + days.days
    else
      # 如果还在有效期内,顺延叠加
      self.expires_at = expires_at + days.days
    end
    
    self.status = 'active'
    self.started_at ||= Time.current
    save!
  end

  # 自动检查并更新过期状态
  def check_expiration!
    return if payment_type == 'buyout' # 买断制不过期
    
    if expires_at.present? && expires_at < Time.current
      update!(status: 'expired')
    end
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
    "#{course.name} - #{payment_type == 'buyout' ? '买断' : '年订阅'}"
  end

  # Always use 'payment' mode (one-time checkout, not recurring subscription)
  def stripe_mode
    'payment'
  end

  def stripe_line_items
    price = payment_type == 'buyout' ? course.buyout_price : course.annual_price
    
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
