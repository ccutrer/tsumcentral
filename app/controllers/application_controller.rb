class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  def require_user_or_admin
    return if admin?
    require_user
  end

  def require_user
    redirect_to login_url unless current_user
  end

  def current_user
    @current_user ||= session[:player_id] && Player.find(session[:player_id])
  end
  helper_method :current_user

  def require_admin
    unless admin?
      respond_to do |format|
        format.html { redirect_to login_url unless admin? }
        format.json { render :unauthorized, json: {} }
      end
    end
  end

  def admin?
    Rails.application.secrets[:shared_secret].present? && request.authorization &&
      (auth_parts = request.authorization.split(' ', 2)) &&
      auth_parts[0] == 'Bearer' &&
      auth_parts[1] == Rails.application.secrets[:shared_secret]
  end
end
