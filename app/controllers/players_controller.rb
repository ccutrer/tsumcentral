class PlayersController < ApplicationController
  def index
    respond_to do |format|
      format.json { Player.all.map(&:as_json) }
      format.html
    end
  end

  def show
    @player = Player.find_by(name: params[:id])
    respond_to do |format|
      format.json { @player.as_json }
      format.html
    end
  end

  def pause
    player = Player.find_by(name: params[:id])
    player.paused_until = Time.zone.now + 1.hour
    player.save!
    redirect_to player_path(player)
  end

  def unpause
    player = Player.find_by(name: params[:id])
    player.paused_until = nil
    player.save! if player.changed?
    redirect_to player_path(player)
  end
end