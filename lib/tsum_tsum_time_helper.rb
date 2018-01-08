module TsumTsumTimeHelper
  extend self

  GAME_TIME_ZONE = 'Asia/Tokyo'

  def end_of_last_game_day
    Time.now.in_time_zone(GAME_TIME_ZONE).beginning_of_day
  end

  def end_of_last_game_week
    Time.now.in_time_zone(GAME_TIME_ZONE).beginning_of_week
  end

end
