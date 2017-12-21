class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  def require_user_or_admin
    return if admin?
    return redirect_to login_url unless session[:player_id]
    @current_user = Player.find(session[:player_id])
    redirect_to login_url unless @current_user
  end

  def require_admin
    redirect_to login_url unless admin?
  end

  def admin?
    false
  end
end
