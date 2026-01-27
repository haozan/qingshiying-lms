class User < ApplicationRecord
  MIN_PASSWORD = 4
  GENERATED_EMAIL_SUFFIX = "@generated-mail.clacky.ai"

  has_secure_password validations: false

  # ========== Role-based Access Control (Optional) ==========
  # If you need roles (premium, moderator, etc.), add a `role` field:
  #   rails g migration AddRoleToUsers role:string
  #   # In migration: add_column :users, :role, :string, default: 'user', null: false
  #   # Then add in this model:
  #   ROLES = %w[user premium moderator].freeze
  #   validates :role, inclusion: { in: ROLES }
  #   def premium? = role == 'premium'
  #   def moderator? = role == 'moderator'
  # ==========================================================

  # ========== Multi-Role Separate Routes (e.g. Doctor/Patient) ==========
  # For apps needing separate signup/login pages per role:
  #   1. ROLES = %w[doctor patient].freeze
  #   2. Add scoped routes: scope '/doctor', as: 'doctor' do ... end
  #   3. In RegistrationsController#create: @user.role = params[:role]
  #   4. Create role-specific views: sessions/new_doctor.html.erb
  #   5. For extra fields per role, use polymorphic Profile:
  #      has_one :doctor_profile, dependent: :destroy
  #      has_one :patient_profile, dependent: :destroy
  #      def profile = doctor? ? doctor_profile : patient_profile
  # See generator output for full setup instructions.
  # ======================================================================

  generates_token_for :email_verification, expires_in: 2.days do
    email
  end
  generates_token_for :password_reset, expires_in: 20.minutes

  has_many :sessions, dependent: :destroy

  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }

  validates :password, allow_nil: true, length: { minimum: MIN_PASSWORD }, if: :password_required?
  validates :password, confirmation: true, if: :password_required?

  normalizes :email, with: -> { _1.strip.downcase }

  before_validation if: :email_changed?, on: :update do
    self.verified = false
  end

  after_update if: :password_digest_previously_changed? do
    sessions.where.not(id: Current.session).delete_all
  end

  # OAuth methods
  def self.from_omniauth(auth)
    name = auth.info.name.presence || "#{SecureRandom.hex(10)}_user"
    email = auth.info.email.presence || User.generate_email(name)

    # First, try to find user by email
    user = find_by(email: email)
    if user
      user.update(provider: auth.provider, uid: auth.uid)
      return user
    end

    # Then, try to find user by provider and uid
    user = find_by(provider: auth.provider, uid: auth.uid)
    return user if user

    # If not found, create a new user
    verified = !email.end_with?(GENERATED_EMAIL_SUFFIX)
    create(
      name: name,
      email: email,
      provider: auth.provider,
      uid: auth.uid,
      verified: verified,
    )
  end

  def self.generate_email(name)
    if name.present?
      name.downcase.gsub(' ', '_') + GENERATED_EMAIL_SUFFIX
    else
      SecureRandom.hex(10) + GENERATED_EMAIL_SUFFIX
    end
  end

  public

  def oauth_user?
    provider.present? && uid.present?
  end

  def email_was_generated?
    email.end_with?(GENERATED_EMAIL_SUFFIX)
  end

  def password_required?
    return false if oauth_user?
    password_digest.blank? || password.present?
  end

  # Course-related associations
  has_many :subscriptions, dependent: :destroy
  has_many :courses, through: :subscriptions
  has_many :progresses, dependent: :destroy
  has_many :homeworks, dependent: :destroy
  has_many :offline_bookings, dependent: :destroy
  has_many :payments, dependent: :destroy

  # 检查用户是否有课程权限
  def has_access_to?(course)
    subscription = subscriptions.find_by(course: course, status: 'active')
    return false unless subscription

    # 检查订阅过期时间
    subscription.expires_at.nil? || subscription.expires_at > Time.current
  end

  # 获取用户最近学习的课程和课节
  def last_learning_position
    progress = progresses.order(updated_at: :desc).first
    return nil unless progress

    {
      lesson: progress.lesson,
      chapter: progress.lesson.chapter,
      course: progress.lesson.chapter.course
    }
  end

  # 检查用户是否有线下预约资格
  # 逻辑：有任一课程订阅，且从最后购买的课程日期起一年内，且未被爽约惩罚
  def offline_booking_eligible?
    return false unless subscriptions.active.any?
    
    # 获取最后购买的课程订阅
    latest_subscription = subscriptions.active.order(started_at: :desc).first
    return false if latest_subscription.started_at.nil?
    
    # 检查是否在一年有效期内
    return false unless Time.current < (latest_subscription.started_at + 1.year)
    
    # 检查是否被爽约惩罚
    !banned_from_booking?
  end
  
  # 获取线下预约资格到期日期
  def offline_booking_expires_at
    latest_subscription = subscriptions.active.order(started_at: :desc).first
    return nil if latest_subscription.nil? || latest_subscription.started_at.nil?
    
    latest_subscription.started_at + 1.year
  end
  
  # 获取当年爽约次数
  def no_show_count_this_year
    offline_bookings.no_show
      .joins(:offline_schedule)
      .where('EXTRACT(YEAR FROM offline_schedules.schedule_date) = ?', Time.current.year)
      .count
  end
  
  # 检查是否因爽约被禁止预约（当年爽约3次）
  def banned_from_booking?
    no_show_count_this_year >= 3
  end
  
  # 获取剩余可爽约次数
  def remaining_no_show_chances
    [3 - no_show_count_this_year, 0].max
  end

  # write your own code here

end
