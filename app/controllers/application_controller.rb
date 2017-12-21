class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  def require_user_or_admin
    return if admin?
    return redirect_to login_url unless session[:player_id]
    @current_user = Player.find(session[:player_id])
    redirect_to login_url unless @current_user
  end

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
