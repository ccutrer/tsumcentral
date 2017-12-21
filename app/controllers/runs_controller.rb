class RunsController < ApplicationController
  protect_from_forgery except: [:create, :end]
  before_action :require_admin

  def create
    player = Player.find_by(name: params[:id])
    player.runs.where(ended_at: nil).update_all(ended_at: Time.zone.now)
    player.runs.create!
    render plain: "OK\n"
  end

  def end
    player = Player.find_by(name: params[:id])
    run = player.runs.last!
    run.ended_at = Time.zone.now
    run.hearts_given = params[:hearts_given].to_i if params[:hearts_given]
    run.save!
    render plain: "OK\n"
  end
end
