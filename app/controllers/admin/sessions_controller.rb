class Admin::SessionsController < Admin::BaseController
  skip_before_action :authenticate_admin!, only: [:new, :create]
  skip_before_action :check_first_login_password_hint, raise: false

  before_action do
    @full_render = true
  end

  before_action :check_admin_session_cookie_availability, only: [:new]
  before_action :check_rate_limit, only: [:create]

  def new
    @first_login = first_admin?
  end

  def create
    create_first_admin_or_reset_password!
    admin = Administrator.find_by(name: params[:name])
    if admin && admin.authenticate(params[:password])
      admin_sign_in(admin)
      AdminOplogService.log_login(admin, request)
      redirect_to admin_root_path
    else
      flash.now[:alert] = '用户名或密码错误'
      @first_login = first_admin?
      render 'new', status: :unprocessable_entity
    end
  end

  def destroy
    AdminOplogService.log_logout(current_admin, request) if current_admin
    admin_sign_out
    redirect_to admin_login_path
  end

  private

  def check_rate_limit
    key = "login_attempts:#{request.ip}"
    attempts = Rails.cache.read(key).to_i

    if attempts >= 5
      flash.now[:alert] = '登录尝试次数过多。请稍后再试。'
      render 'new', status: :too_many_requests
    else
      Rails.cache.write(key, attempts + 1, expires_in: 1.minute)
    end
  end

  def create_first_admin_or_reset_password!
    return unless first_admin?
    admin = Administrator.find_by(name: 'admin')
    if admin.nil?
      logger.info("System have no admins, create the first one")
      admin = Administrator.new(name: 'admin', password: 'admin', role: 'super_admin')
      admin.save!(validate: false)
    else
      admin.update!(password: 'admin', password_confirmation: 'admin')
    end
  end

  def first_admin?
    return true if Administrator.count.zero?
    Administrator.exists?(name: 'admin', first_login: true)
  end

  def check_admin_session_cookie_availability
    # Check if session cookie is available (privacy + iframe mode detection)
    if request.session.id.nil? || !cookies.key?('_clacky_app_session')
      @privacy_iframe_mode = true
      flash.now[:alert] = "您的浏览器可能处于隐私模式或在 iframe 中。" \
                          "登录功能可能无法正常工作。" \
                          "请使用右上角按钮在新窗口中打开。"
    else
      @privacy_iframe_mode = false
    end
  end
end
