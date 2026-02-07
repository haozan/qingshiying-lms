class CoursesController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show]
  before_action :set_course, only: [:show, :purchase]

  def index
    @courses = Course.active.ordered
    
    # 获取用户最近学习位置
    @last_position = current_user.last_learning_position if current_user
    
    # 获取用户的订阅信息
    @subscriptions = current_user ? current_user.subscriptions.active.index_by(&:course_id) : {}
    
    # 获取 3 课联报套餐（只显示第一个 active 的套餐）
    @course_bundle = CourseBundle.active.first
    @bundle_subscription = current_user && @course_bundle ? current_user.bundle_subscriptions.active.find_by(course_bundle: @course_bundle) : nil
  end

  def show
    @subscription = current_user.subscriptions.find_by(course: @course) if current_user
    @first_lesson = @course.lessons.first
  end

  def purchase
    # 检查是否已经订阅
    if current_user.subscriptions.active.exists?(course: @course)
      redirect_to course_path(@course), alert: '您已经购买过该课程'
      return
    end

    # 创建订阅记录（状态为 pending，支付成功后激活）
    subscription = current_user.subscriptions.create!(
      course: @course,
      status: 'pending'
    )

    # 创建支付记录，关联到订阅
    price = @course.early_bird_price.presence || @course.current_price.presence || @course.annual_price
    
    @payment = Payment.create!(
      payable: subscription,
      user: current_user,
      amount: price,
      currency: 'cny',
      status: 'pending'
    )

    # 初始化 Stripe 支付
    stripe_service = StripePaymentService.new(@payment, request)
    result = stripe_service.call

    if result[:success]
      # 重定向到 Stripe 结账页面
      redirect_to result[:checkout_session].url, allow_other_host: true
    else
      @payment.mark_as_failed!
      subscription.destroy  # 清理未支付的订阅
      redirect_to courses_path, alert: "支付初始化失败：#{result[:error]}"
    end
  end

  private
  
  def set_course
    @course = Course.friendly.find(params[:id])
  end
  
  def has_free_lessons?
    @course.lessons.where(free: true).any?
  end
end
