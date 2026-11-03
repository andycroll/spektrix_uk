require_relative '../../test_helper'

class SpektrixUk::PerformanceTest < Minitest::Test
  include FixturesHelper

  DATE = Date.new(2026, 11, 1)
  YEAR_AHEAD = DATE + 365

  def test_at_returns_performances_on_the_requested_date_only
    performances = performances_at('broadway')

    assert(performances.all? { |p| p.instance_of?(SpektrixUk::Performance) })
    assert_equal 2, performances.count
    assert_equal [DATE], performances.map(&:showing_on).uniq
  end

  def test_at_accepts_symbol_id
    assert_equal 2, performances_at(:broadway).count
  end

  def test_at_sets_cinema_details
    performances = performances_at('broadway')

    assert_equal ['broadway'], performances.map(&:cinema_id).uniq
    assert_equal ['Broadway'], performances.map(&:cinema_name).uniq
  end

  def test_at_sorts_by_start
    performances = year_of('tyneside')

    assert_equal performances.map(&:starting_at).sort, performances.map(&:starting_at)
  end

  def test_at_parses_first_performance
    performance = performances_at('broadway').first

    assert_equal 'Wicker', performance.film_name
    assert_equal 2026, performance.film_year
    assert_equal Time.utc(2026, 11, 1, 15, 30), performance.starting_at
    assert_equal '2d', performance.dimension
    assert_equal %w(audio_described), performance.variant
    assert_equal 'https://www.broadway.org.uk/book/1223024', performance.booking_url
  end

  def test_at_reads_every_advertised_date_in_two_requests
    performances = year_of('broadway')

    assert_equal 9, performances.count
    assert_equal Date.new(2027, 4, 4), performances.last.showing_on
    assert_requested :get, %r{/events\?instanceStart_from=2026-11-01&instanceStart_to=2027-11-02}, times: 1
    assert_requested :get, %r{/instances\?startFrom=2026-11-01&startTo=2027-11-02}, times: 1
  end

  def test_at_keeps_films_only
    names = SpektrixUk::Internal::Venue::ALL.keys.flat_map { |id| year_of(id).map(&:film_name) }.uniq

    assert_includes names, 'Manon'
    assert_includes names, 'The Nutcracker'
    ['Talk Cinema - Evening', 'Meet the 2026 Booker Prize Winner', 'Showroom Pub Quiz',
     'FFS 2026 Festival Pass', "August Wilson's Fences", 'KIDS BUNDLE DEALS'].each do |name|
      refute_includes names, name
    end
  end

  def test_at_keeps_the_picture_house_from_a_shared_account
    names = year_of('hpph').map(&:film_name).uniq

    assert_equal ['Wicker', 'Between Goodbyes', "It's a Wonderful Life"], names
  end

  def test_at_drops_midnight_placeholders
    starts = year_of('hpph').map { |p| p.starting_at.strftime('%H:%M') }

    refute_includes starts, '00:00'
    refute_includes year_of('hpph').map(&:film_name), 'Josephine'
  end

  def test_at_drops_cancelled_instances
    instances = JSON.parse(instances_json('broadway'))
    instances.each { |instance| instance['cancelled'] = true if instance['start'].start_with?('2026-11-01') }
    stub_api('broadway', instances: JSON.generate(instances))

    assert_empty SpektrixUk::Performance.at('broadway', from: DATE, to: DATE)
  end

  def test_at_reads_variants_and_years_by_venue
    tyneside = year_of('tyneside')

    assert_equal %w(35mm audio_described), tyneside.find { |p| p.booking_url.end_with?('/1898401') }.variant
    assert_equal 2018, tyneside.find { |p| p.film_name == 'The Grinch' }.film_year
    assert_equal %w(arts audio_described subtitled), tyneside.find { |p| p.booking_url.end_with?('/1865001') }.variant
    assert_equal %w(audio_described baby), year_of('home').find { |p| p.film_name == 'Klara and the Sun' }.variant
  end

  def test_at_rejects_range_ending_before_start
    assert_raises(ArgumentError) { SpektrixUk::Performance.at('tyneside', from: DATE, to: DATE - 1) }
  end

  def test_at_unknown_cinema
    assert_raises(KeyError) { SpektrixUk::Performance.at('nowhere', from: DATE, to: DATE) }
  end

  def test_new_sets_defaults
    performance = SpektrixUk::Performance.new(
      film_name: 'Carol', cinema_id: 'home', cinema_name: 'HOME',
      starting_at: Time.utc(2013, 9, 12, 11, 0)
    )

    assert_nil performance.booking_url
    assert_equal '2d', performance.dimension
    assert_nil performance.festival
    assert_nil performance.film_year
    refute performance.subtitled?
    assert_equal [], performance.variant
  end

  private

  def performances_at(cinema_id)
    stub_api(cinema_id.to_s)
    SpektrixUk::Performance.at(cinema_id, from: DATE, to: DATE)
  end

  def year_of(cinema_id)
    stub_api(cinema_id)
    SpektrixUk::Performance.at(cinema_id, from: DATE, to: YEAR_AHEAD)
  end
end
