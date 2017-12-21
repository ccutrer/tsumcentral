class SessionsController < ApplicationController
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
end
