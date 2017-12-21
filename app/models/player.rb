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

  def next_run
    last_run = runs.last

    result = last_run.created_at + 38.minutes if last_run
    result ||= Time.zone.now
    [result, paused_until].compact.max
  end

  def as_json
    {
      name: name,
      next_run: next_run
    }
  end
end
