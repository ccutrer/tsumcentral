class Run < ApplicationRecord
  belongs_to :player

  scope :not_running, -> { where.not(ended_at: nil) }

  def runtime
    ended_at && ended_at - created_at
  end

  def failed?
    !ended_at.nil? && hearts_given.nil?
  end

  def summary
    if !ended_at
      "running"
    elsif failed?
      "failed"
    else
      "#{hearts_given} hearts given"
    end
  end
end
