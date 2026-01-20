class Identity::EmailVerificationsController < ApplicationController
  before_action :authenticate_user!, only: :create

  before_action :set_user, only: :show

  def show
    @user.update! verified: true
    redirect_to profile_path, notice: "感谢您验证邮箱地址"
  end

  def create
    if current_user.email_was_generated?
      redirect_to profile_path, alert: "您的邮箱是由系统生成的，无法验证。请更新为有效的邮箱地址。"; return
    end
    send_email_verification
    redirect_to profile_path, notice: "我们已向您的邮箱发送了验证邮件"
  end

  private

  def set_user
    @user = User.find_by_token_for!(:email_verification, params[:sid])
  rescue StandardError
    redirect_to edit_identity_email_path, alert: "邮箱验证链接无效或已过期"
  end

  def send_email_verification
    UserMailer.with(user: Current.user).email_verification.deliver_later
  end
end
