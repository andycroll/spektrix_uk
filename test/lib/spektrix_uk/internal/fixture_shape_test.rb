require_relative '../../../test_helper'

class FixtureShapeTest < Minitest::Test
  include ApiShapes
  include FixturesHelper

  def test_events_fixtures_match_shape
    SpektrixUk::Internal::Venue::ALL.each_value do |venue|
      assert_events_shape(venue, JSON.parse(events_json(venue.id)))
    end
  end

  def test_instances_fixtures_match_shape
    SpektrixUk::Internal::Venue::ALL.each_value do |venue|
      assert_instances_shape(venue, JSON.parse(instances_json(venue.id)))
    end
  end
end
