class BundleSubscription < ApplicationRecord
  belongs_to :user
  belongs_to :course_bundle
  has_one :payment, as: :payable, dependent: :destroy

  # Validations
  validates :status, presence: true, inclusion: { in: %w[pending active expired cancelled] }

  # Scopes
  scope :active, -> { where(status: 'active') }

  # 激活套餐并创建所有课程订阅
  def activate!
    transaction do
      update!(status: 'active', started_at: Time.current)
      
      # 为用户创建所有包含的课程订阅
      course_bundle.courses.each do |course|
        user.subscriptions.find_or_create_by!(course: course) do |sub|
          sub.status = 'active'
          sub.started_at = Time.current
        end
      end
    end
  end

  def active?
    status == 'active'
  end

  # ============== Payment Interface (REQUIRED by Payment model) ==============
  def customer_name
    user.email.split('@').first
  end

  def customer_email
    user.email
  end

  def payment_description
    "#{course_bundle.name} - 套餐订阅（永久内容+一年线下）"
  end

  def stripe_mode
    'payment'
  end

  def stripe_line_items
    price = course_bundle.early_bird_price.presence || course_bundle.current_price.presence || course_bundle.original_price
    
    [{
      price_data: {
        currency: 'cny',
        product_data: { 
          name: course_bundle.name,
          description: payment_description
        },
        unit_amount: (price * 100).to_i
      },
      quantity: 1
    }]
  end
end
