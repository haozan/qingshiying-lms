class Sessions::OmniauthController < ApplicationController
  skip_before_action :verify_authenticity_token, raise: false

  def create
    @user = User.from_omniauth(omniauth)

    if @user.persisted?
      session_record = @user.sessions.create!
      cookies.signed.permanent[:session_token] = { value: session_record.id, httponly: true }

      redirect_to root_path, notice: "#{omniauth.provider.humanize} 登录成功"
    else
      flash[:alert] = handle_password_errors(@user)
      redirect_to sign_in_path
    end
  end

  def failure
    error_type = params[:message] || request.env['omniauth.error.type']

    error_message = case error_type.to_s
    when 'access_denied'
      "授权已取消。如果您想登录，请重试。"
    when 'invalid_credentials'
      "无效的凭据。请检查您的信息并重试。"
    when 'timeout'
      "认证超时。请重试。"
    else
      "认证失败：#{error_type&.to_s&.humanize || '未知错误'}"
    end

    flash[:alert] = error_message
    redirect_to sign_in_path
  end

  private

  def omniauth
    request.env["omniauth.auth"]
  end
end
