require_relative '../../../../test_helper'

class SpektrixUk::Internal::Parser::InstanceTest < Minitest::Test
  def test_to_hash
    expected = {
      booking_url: 'https://tynesidecinema.co.uk/book-online/1891006',
      dimension: '2d',
      festival: nil,
      film_name: 'Little Women',
      film_year: 2019,
      starting_at: Time.utc(2026, 12, 6, 14, 0),
      title: 'Little Women (2019) [2026]',
      variant: []
    }

    assert_equal expected, parse
  end

  def test_start_utc_with_zone
    assert_equal Time.utc(2027, 6, 1, 18), parse(instance: { 'startUtc' => '2027-06-01T18:00:00Z' })[:starting_at]
  end

  def test_london_summer_time_without_start_utc
    instance = { 'start' => '2027-06-01T19:00:00', 'startUtc' => nil }

    assert_equal Time.utc(2027, 6, 1, 18), parse(instance: instance)[:starting_at]
  end

  def test_three_d_from_attribute_or_title
    assert_equal '3d', parse(instance: { 'attribute_3DScreening' => true })[:dimension]
    assert_equal '3d', parse(event: { 'name' => 'Avatar: Fire and Ash 3D' })[:dimension]
    assert_equal '2d', parse(venue: 'broadway', instance: { 'attribute_3DScreening' => true })[:dimension]
  end

  def test_variants_from_event_instance_and_title
    hash = parse(
      event: { 'name' => 'Baby Kino: Wicker [+ Filmmaker Q&A]', 'attribute_Genre1' => 'Concert Film/Event Cinema' },
      instance: { 'attribute_SubtitledForHardOfHearing' => true, 'attribute_TynesideBabyClub' => true }
    )

    assert_equal %w(arts subtitled baby q&a), hash[:variant]
  end

  def test_variants_matching_values
    hash = parse(venue: 'home', instance: { 'attribute_AudioDescription' => 'AD', 'attribute_Relaxed' => '' })

    assert_equal %w(audio_described), hash[:variant]
  end

  def test_film_year_from_attribute
    assert_equal 1992, parse(venue: 'broadway', event: { 'attribute_Year' => '1992' })[:film_year]
  end

  def test_film_year_from_title_when_attribute_is_not_a_year
    assert_equal 2019, parse(venue: 'broadway', event: { 'attribute_Year' => '1992 / 2021' })[:film_year]
  end

  def test_festival_from_title
    festival = parse(event: { 'name' => 'CFF: Wicker' })[:festival]

    assert_equal Cinebase::Festival.new(name: 'Cambridge Film Festival', year: 2026), festival
  end

  def test_performances_read_series_from_the_title
    hash = parse(event: { 'name' => 'Parsifal - Met Opera 26/27' })
    performance = SpektrixUk::Performance.new(hash.merge(cinema_id: 'tyneside', cinema_name: 'Tyneside Cinema'))

    assert_equal 'Parsifal', performance.film_name
    assert_equal 'Met Opera', performance.event.name
    assert_equal %w(arts), performance.variant
  end

  def test_booking_url_by_venue
    assert_equal 'https://www.broadway.org.uk/book/1891006', parse(venue: 'broadway')[:booking_url]
    assert_equal 'https://tickets.hpph.co.uk/leedsheritagetheatres/website/ChooseSeats.aspx?EventInstanceId=1891006',
                 parse(venue: 'hpph')[:booking_url]
  end

  private

  def parse(venue: 'tyneside', event: {}, instance: {})
    event = { 'id' => '1E', 'name' => 'Little Women (2019) [2026]' }.merge(event)
    instance = {
      'id' => '1891006AJDGTKTHPKTMCTPGBBDLCPBPLC',
      'event' => { 'id' => '1E' },
      'start' => '2026-12-06T14:00:00',
      'startUtc' => '2026-12-06T14:00:00',
      'cancelled' => false
    }.merge(instance)
    SpektrixUk::Internal::Parser::Instance.new(
      instance, event: event, venue: SpektrixUk::Internal::Venue.find(venue)
    ).to_hash
  end
end
