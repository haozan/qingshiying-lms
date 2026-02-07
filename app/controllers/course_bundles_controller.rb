class CourseBundlesController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show]
  before_action :set_course_bundle, only: [:show, :purchase]

  def index
    @course_bundles = CourseBundle.active
    @bundle_subscriptions = current_user ? current_user.bundle_subscriptions.active.index_by(&:course_bundle_id) : {}
  end

  def show
    @bundle_subscription = current_user.bundle_subscriptions.find_by(course_bundle: @course_bundle) if current_user
  end

  def purchase
    # 检查是否已经购买
    if current_user.bundle_subscriptions.active.exists?(course_bundle: @course_bundle)
      redirect_to courses_path, alert: '您已经购买过该套餐'
      return
    end

    # 创建套餐订阅记录（状态为 pending，支付成功后激活）
    bundle_subscription = current_user.bundle_subscriptions.create!(
      course_bundle: @course_bundle,
      status: 'pending'
    )

    # 创建支付记录，关联到套餐订阅
    price = @course_bundle.early_bird_price.presence || @course_bundle.current_price.presence || @course_bundle.original_price
    
    @payment = Payment.create!(
      payable: bundle_subscription,
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
      bundle_subscription.destroy  # 清理未支付的订阅
      redirect_to courses_path, alert: "支付初始化失败：#{result[:error]}"
    end
  end

  private
  
  def set_course_bundle
    @course_bundle = CourseBundle.find(params[:id])
  end
end
