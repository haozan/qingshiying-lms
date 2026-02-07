class CourseBundle < ApplicationRecord
  # Associations
  has_many :course_bundle_items, -> { order(position: :asc) }, dependent: :destroy
  has_many :courses, through: :course_bundle_items
  has_many :bundle_subscriptions, dependent: :destroy

  # Validations
  validates :name, presence: true
  validates :status, presence: true, inclusion: { in: %w[active inactive] }
  validates :original_price, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :current_price, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :early_bird_price, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  # Scopes
  scope :active, -> { where(status: 'active') }

  # Stripe 支付集成方法
  def stripe_line_items
    price = early_bird_price.presence || current_price.presence || original_price
    [
      {
        price_data: {
          currency: 'cny',
          product_data: {
            name: name,
            description: description.presence || "青狮营课程套餐"
          },
          unit_amount: (price * 100).to_i
        },
        quantity: 1
      }
    ]
  end

  def stripe_mode
    'payment'
  end

  def customer_name
    "青狮营学员"
  end

  def customer_email
    nil
  end

  def payment_description
    "青狮营 - #{name}"
  end
end
