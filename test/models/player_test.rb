require 'test_helper'

class PlayerTest < ActiveSupport::TestCase
  def setup
    travel_to Time.zone.now
    @player = Player.create!(name: 'cody', password: 'password')
  end

  def teardown
    travel_back
  end

  test "next_run returns now for a new player" do
    assert_equal Time.zone.now, @player.next_run
  end

  test "next_run returns half the runtime plus an hour after the previous run finished" do
    @player.runs.create!(created_at: 8.minutes.ago, ended_at: Time.zone.now, hearts_given: 75)
    assert_equal 26.minutes.from_now, @player.next_run
  end

  test "next_run returns 1 hour past two runs ago" do
    @player.runs.create!(created_at: 43.minutes.ago, ended_at: 35.minutes.ago, hearts_given: 75)
    @player.runs.create!(created_at: 1.minute.ago, ended_at: Time.zone.now, hearts_given: 0)
    assert_equal 25.minutes.from_now, @player.next_run
  end
end
