require 'tsum_tsum_time_helper'

class Player < ApplicationRecord
  has_secure_password

  has_many :runs

  def to_param
    name
  end

  def current_run
    runs.reverse_order.where(ended_at: nil).take
  end

  def last_run
    runs.reverse_order.where.not(ended_at: nil).take
  end

  def running?
    !!current_run
  end

  def paused?
    paused_until && paused_until > Time.zone.now
  end

  def heart_sets(end_of_period = Time.zone.now, timespan = 24.hours)
    last_runs = runs.where.not(hearts_given: [0, nil]).where("ended_at<=? AND ended_at>?", end_of_period, end_of_period - timespan)
    count = 0
    prior_run = nil
    last_runs.reverse.each do |run|
      next if prior_run && prior_run.ended_at - run.ended_at < 60.minutes
      prior_run = run
      count += 1
    end
    count
  end
  alias twenty_four_hour_heart_sets heart_sets

  def last_game_day_heart_sets
    heart_sets(TsumTsumTimeHelper.end_of_last_game_day)
  end

  def last_game_week_heart_sets
    heart_sets(TsumTsumTimeHelper.end_of_last_game_week, 7.days)
  end

  def next_run
    return nil if suspended?
    return Time.zone.now if run_now?

    last_runs = runs.last(2)
    # still running; don't run again
    return nil if last_runs.last&.ended_at.nil?

    succesful_runs = last_runs.select { |run| run.hearts_given.to_i > 0 }

    # no later than 1 hour after a previous run that actually gave hearts completed
    latest = succesful_runs.map(&:ended_at).min&.+ 60.minutes

    unless last_runs.empty?
      # no earlier than half the stride of the slower of the two runs
      earliest = last_runs.last.created_at + 30.minutes + last_runs.sort_by(&:runtime).last.runtime / 2
    end
    # no prior runs? now!
    earliest ||= Time.zone.now

    # choose the earlier of earliest, latest, but subject to a temporary pause
    [[earliest, latest].compact.min, paused_until].compact.max
  end

  def as_json
    next_run = self.next_run
    {
      name: name,
      next_run: next_run&.utc,
      run_now: next_run && next_run <= Time.zone.now
    }
  end
end
