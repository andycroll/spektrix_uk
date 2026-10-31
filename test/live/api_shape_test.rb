require_relative 'live_helper'

class LiveApiShapeTest < Minitest::Test
  include ApiShapes

  def test_events_are_readable
    each_venue { |venue, api| assert_events_shape(venue, api.events(today, today + 14)) }
  end

  def test_instances_are_readable
    each_venue { |venue, api| assert_instances_shape(venue, api.instances(today, today + 14)) }
  end

  private

  def each_venue
    SpektrixUk::Internal::Venue::ALL.each_value do |venue|
      yield venue, SpektrixUk::Internal::Api.new(venue.client)
    end
  end

  def today
    Date.today
  end
end
