# Read fixtures from disk: API responses captured from each venue's Spektrix
# account and trimmed to a few events. They follow the shape in api_shapes.rb.
module FixturesHelper
  private

  def events_json(venue_id)
    read_fixture("api/#{venue_id}/events.json")
  end

  def instances_json(venue_id)
    read_fixture("api/#{venue_id}/instances.json")
  end

  def read_fixture(filepath)
    File.read(File.expand_path("../../fixtures/#{filepath}", __FILE__))
  end

  # Answer the venue's API requests from its fixtures
  def stub_api(venue_id, instances: instances_json(venue_id))
    client = SpektrixUk::Internal::Venue.find(venue_id).client
    stub_request(:get, %r{\Ahttps://system\.spektrix\.com/#{client}/api/v3/events\?})
      .to_return(status: 200, body: events_json(venue_id))
    stub_request(:get, %r{\Ahttps://system\.spektrix\.com/#{client}/api/v3/instances\?})
      .to_return(status: 200, body: instances)
  end
end
