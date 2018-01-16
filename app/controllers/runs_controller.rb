class RunsController < ApplicationController
  protect_from_forgery except: [:create, :end]
  before_action :require_admin

  def create
    player = Player.find_by(name: params[:id])

    # cancel the prior run if it exists
    last = player.runs.last
    Run.where(id: last).update_all(ended_at: Time.zone.now) if last && last.ended_at.nil?

    player.runs.create!
    player.update_attribute(:extend_timeout, false)
    render json: { status: "OK" }
  end

  def end
    player = Player.find_by(name: params[:id])
    run = player.runs.last
    # only finish a run if it wasn't already done
    return render json: { status: "Not Found" }, status: 404 if !run || !run.ended_at.nil?

    run.ended_at = Time.zone.now
    run.hearts_given = params[:hearts_given].to_i if params[:hearts_given].present?
    run.save!
    render json: { status: "OK" }
  end
end
