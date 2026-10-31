require_relative 'live_helper'

class LivePerformanceTest < Minitest::Test
  def test_at_returns_films_at_every_venue
    tomorrow = Date.today + 1

    SpektrixUk::Cinema.all.each do |cinema|
      performances = SpektrixUk::Performance.at(cinema.id, from: tomorrow, to: tomorrow + 6)

      assert(performances.all? { |p| p.instance_of?(SpektrixUk::Performance) })
      assert_operator performances.count, :>, 5, cinema.id
    end
  end

  def test_at_reaches_beyond_the_fortnight
    today = Date.today
    performances = SpektrixUk::Performance.at('tyneside', from: today, to: today + 365)

    assert_operator performances.map(&:showing_on).max, :>, today + 14
  end
end
