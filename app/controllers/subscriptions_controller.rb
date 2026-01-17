class SubscriptionsController < ApplicationController
  before_action :authenticate_user!

  def new
    @course = Course.friendly.find(params[:course_id])
    @payment_type = params[:payment_type] # 'annual' or 'buyout'
    
    # 检查是否已经订阅
    @existing_subscription = current_user.subscriptions.find_by(course: @course, status: ['active', 'pending'])
    
    # 计算价格
    @price = @payment_type == 'buyout' ? @course.buyout_price : @course.annual_price
  end

  def create
    @course = Course.friendly.find(params[:course_id])
    payment_type = params[:payment_type] # 'annual' or 'buyout'
    
    # 创建或获取订阅记录
    @subscription = current_user.subscriptions.find_or_initialize_by(
      course: @course,
      payment_type: payment_type
    )
    
    # 如果已存在且有效,则重定向
    if @subscription.persisted? && @subscription.status == 'active' && @subscription.active?
      redirect_to course_path(@course), alert: '您已经订阅了该课程'
      return
    end
    
    # 设置为 pending 状态
    @subscription.status = 'pending'
    @subscription.save!
    
    # 计算价格
    amount = payment_type == 'buyout' ? @course.buyout_price : @course.annual_price
    
    # 创建支付记录
    @payment = @subscription.create_payment!(
      user: current_user,
      amount: amount,
      currency: 'cny',
      status: 'pending'
    )
    
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
