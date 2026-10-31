require_relative '../../../test_helper'

class SpektrixUk::Internal::ApiTest < Minitest::Test
  include FixturesHelper

  BASE = 'https://system.spektrix.com/tynesidecinema/api/v3'.freeze

  def test_events_with_an_instance_in_the_range
    stub_request(:get, "#{BASE}/events?instanceStart_from=2026-11-01&instanceStart_to=2026-11-03")
      .to_return(status: 200, body: events_json('tyneside'))

    events = api.events(Date.new(2026, 11, 1), Date.new(2026, 11, 3))

    assert_equal 6, events.size
    assert_equal 'Wild Horse Nine', events.first['name']
  end

  def test_instances_in_the_range
    stub_request(:get, "#{BASE}/instances?startFrom=2026-11-01&startTo=2026-11-03")
      .to_return(status: 200, body: instances_json('tyneside'))

    instances = api.instances(Date.new(2026, 11, 1), Date.new(2026, 11, 3))

    assert_equal 24, instances.size
    assert_equal '2026-10-31T14:40:00', instances.first['start']
  end

  def test_errors_omit_body
    stub_request(:get, /#{BASE}/).to_return(status: 500, body: 'secret')

    error = assert_raises(RuntimeError) { api.events(Date.new(2026, 11, 1), Date.new(2026, 11, 3)) }

    assert_equal 'Spektrix HTTP error 500', error.message
  end

  private

  def api
    SpektrixUk::Internal::Api.new('tynesidecinema')
  end
end
