class SessionsController < ApplicationController
  before_action :require_user, only: [:change_password]

  def new
  end

  def create
    player = Player.find_by(name: params[:name])
    if player && player.authenticate(params[:password])
      session.clear
      session[:player_id] = player.id
      redirect_to player_path(player)
    else
      redirect_to login_path
    end
  end

  def destroy
    session.clear

    redirect_to login_path
  end

  def change_password
    return if request.method == 'GET'

    if params[:password].blank? || params[:password] != params[:password_confirmation]
      flash[:error] = "Passwords don't match"
      return redirect_to change_password_url
    end

    current_user.update_attribute(:password, params[:password])

    redirect_to player_path(current_user)
  end
end
