# The parts of Spektrix responses the gem reads. Checked against the trimmed
# fixtures and, in the live suite, against real responses held only in memory.
module ApiShapes
  # Event attributes each venue's film rule reads
  FILM_ATTRIBUTES = {
    'broadway' => %w(attribute_EventCinema attribute_Film),
    'home' => %w(attribute_ShowType),
    'hpph' => %w(attribute_LiveOrFilm attribute_Venue attribute_Website),
    'showroom' => %w(attribute_ShowroomNonFilmEvent),
    'tyneside' => %w(attribute_Medium)
  }.freeze

  DATE_TIME = /\A\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\z/

  private

  def assert_events_shape(venue, events)
    refute_empty events
    attributes = FILM_ATTRIBUTES.fetch(venue.id) + venue.event_variants.keys + [venue.year].compact
    events.each do |event|
      assert_kind_of String, event.fetch('id')
      assert_kind_of String, event.fetch('name')
      attributes.each { |attribute| assert event.key?(attribute), "#{venue.id} event has no #{attribute}" }
    end
  end

  def assert_instances_shape(venue, instances)
    refute_empty instances
    attributes = venue.instance_variants.keys + [venue.three_d].compact
    instances.each do |instance|
      assert_match(/\A\d+[A-Z]+\z/, instance.fetch('id'))
      assert_kind_of String, instance.fetch('event').fetch('id')
      assert_match DATE_TIME, instance.fetch('start')
      assert_match DATE_TIME, instance.fetch('startUtc')
      assert_includes [true, false], instance.fetch('cancelled')
      attributes.each { |attribute| assert instance.key?(attribute), "#{venue.id} instance has no #{attribute}" }
    end
  end
end
