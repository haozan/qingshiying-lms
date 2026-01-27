class SubscriptionsController < ApplicationController
  before_action :authenticate_user!

  def new
    @course = Course.friendly.find(params[:course_id])
    
    # 只检查已支付的订阅（active），未支付的（pending）不算已订阅
    @existing_subscription = current_user.subscriptions.find_by(course: @course, status: 'active')
    
    # 使用三档价格系统：优先使用早鸟价，其次现价，最后回退到旧价格
    @price = @course.early_bird_price.presence || @course.current_price.presence || @course.annual_price
  end

  def create
    @course = Course.friendly.find(params[:course_id])
    
    # 创建或获取订阅记录（统一为 annual 类型）
    @subscription = current_user.subscriptions.find_or_initialize_by(
      course: @course,
      payment_type: 'annual'
    )
    
    # 如果已存在且有效,则重定向
    if @subscription.persisted? && @subscription.status == 'active' && @subscription.active?
      redirect_to course_path(@course), alert: '您已经订阅了该课程'
      return
    end
    
    # 免费课程：直接创建 active 订阅，无需支付
    if @course.free?
      @subscription.status = 'active'
      @subscription.started_at = Time.current
      @subscription.save!
      redirect_to course_path(@course), notice: '报名成功！您现在可以开始学习了'
      return
    end
    
    # 付费课程：设置为 pending 状态，进入支付流程
    @subscription.status = 'pending'
    @subscription.save!
    
    # 使用三档价格系统：优先使用早鸟价，其次现价，最后回退到旧价格
    amount = @course.early_bird_price.presence || @course.current_price.presence || @course.annual_price
    
    # 如果已有未支付的 payment，重用它；否则创建新的
    if @subscription.payment&.pending?
      @payment = @subscription.payment
      # 更新价格（以防课程价格变动）
      @payment.update!(amount: amount)
    else
      # 删除旧 payment（如果有），创建新的
      @subscription.payment&.destroy
      @payment = @subscription.create_payment!(
        user: current_user,
        amount: amount,
        currency: 'cny',
        status: 'pending'
      )
    end
    
    # 重定向到 Stripe 支付页面 (test环境直接成功)
    if Rails.env.test?
      redirect_to course_path(@course), notice: '订阅创建成功'
    else
      redirect_to pay_payment_path(@payment), data: { turbo_method: :post }
    end
  end

  def destroy
    # 用户取消订阅(仅支持已过期的订阅)
    @subscription = current_user.subscriptions.find(params[:id])
    
    if @subscription.status == 'expired'
      @subscription.update!(status: 'cancelled')
      redirect_to dashboard_progresses_path, notice: '订阅已取消'
    else
      redirect_to dashboard_progresses_path, alert: '无法取消有效订阅'
    end
  end

  private
  # Write your private methods here
end
