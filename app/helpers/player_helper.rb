module PlayerHelper
  def status(player)
    if player.running?
      "running for #{distance_of_time_in_words(Time.zone.now - player.current_run.created_at)}"
    elsif player.paused?
      "paused for #{distance_of_time_in_words(player.paused_until - Time.zone.now)}"
    else
      next_run = player.next_run
      if next_run < Time.zone.now
        "waiting to run"
      else
        "idle for the next #{distance_of_time_in_words(next_run - Time.zone.now)}"
      end
    end
  end
end
