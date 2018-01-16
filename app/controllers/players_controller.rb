class PlayersController < ApplicationController
  before_action :require_user_or_admin
  before_action :find_player, except: :index
  before_action :require_admin, only: [:suspend, :unsuspend, :run_now]

  def index
    return redirect_to player_url(@current_user) unless admin?

    respond_to do |format|
      format.json { render json: Player.all.map(&:as_json) }
      format.html
    end
  end

  def show
    respond_to do |format|
      format.json { render json: @player.as_json }
      format.html
    end
  end

  def pause
    @player.run_now = false
    @player.update_attribute(:paused_until, Time.zone.now + 1.hour)
    redirect_to player_path(@player)
  end

  def unpause
    @player.update_attribute(:paused_until, nil)
    redirect_to player_path(@player)
  end

  def suspend
    @player.update_attribute(:suspended, true)
    redirect_to player_path(@player)
  end

  def unsuspend
    @player.update_attribute(:suspended, false)
    redirect_to player_path(@player)
  end

  def run_now
    @player.paused_until = nil
    @player.update_attribute(:run_now, true)
    redirect_to player_path(@player)
  end

  def extend_timeout
    @player.update_attribute(:extend_timeout, true)
    redirect_to player_path(@player)
  end

  protected

  def find_player
    @player = Player.find_by(name: params[:id])
    return render :unauthorized unless admin? || @player == @current_user
  end

  def require_admin
    return render :unauthorized unless admin?
  end
end