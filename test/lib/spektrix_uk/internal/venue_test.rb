require_relative '../../../test_helper'

class SpektrixUk::Internal::VenueTest < Minitest::Test
  def test_find
    assert_equal 'tynesidecinema', SpektrixUk::Internal::Venue.find(:tyneside).client
  end

  def test_find_unknown
    assert_raises(KeyError) { SpektrixUk::Internal::Venue.find('nowhere') }
  end

  def test_tyneside_films
    assert film?('tyneside', 'attribute_Medium' => 'Live Action')
    refute film?('tyneside', 'attribute_Medium' => 'Non-Film')
  end

  def test_broadway_films_include_event_cinema
    assert film?('broadway', 'attribute_Film' => true, 'attribute_EventCinema' => false)
    assert film?('broadway', 'attribute_Film' => false, 'attribute_EventCinema' => true)
    refute film?('broadway', 'attribute_Film' => false, 'attribute_EventCinema' => false)
  end

  def test_showroom_films
    assert film?('showroom', 'attribute_ShowroomNonFilmEvent' => false)
    refute film?('showroom', 'attribute_ShowroomNonFilmEvent' => true)
  end

  def test_hpph_films_at_the_picture_house_only
    film = { 'attribute_LiveOrFilm' => 'Film', 'attribute_Website' => 'HPPH', 'attribute_Venue' => 'Hyde Park Picture House' }

    assert film?('hpph', film)
    assert film?('hpph', film.merge('attribute_Venue' => ''))
    refute film?('hpph', film.merge('attribute_Venue' => 'City Varieties Music Hall'))
    refute film?('hpph', film.merge('attribute_Website' => 'Theatres'))
    refute film?('hpph', film.merge('attribute_LiveOrFilm' => 'Live'))
  end

  def test_home_films
    assert film?('home', 'attribute_ShowType' => 'Film')
    refute film?('home', 'attribute_ShowType' => 'Theatre')
  end

  def test_passes_and_bundles_are_not_films
    ['FFS 2026 Festival Pass', 'KIDS BUNDLE DEALS', 'Film Studies - Lecture 2 (Wong Kar Wai)'].each do |name|
      refute film?('showroom', 'attribute_ShowroomNonFilmEvent' => false, 'name' => name), name
    end
  end

  def test_address
    expected = {
      street_address:   '73 Brudenell Road',
      extended_address: nil,
      locality:         'Leeds',
      region:           nil,
      postal_code:      'LS6 1JD',
      country_name:     'United Kingdom'
    }

    assert_equal expected, SpektrixUk::Internal::Venue.find('hpph').address
  end

  def test_every_venue_has_coordinates_and_a_booking_link
    SpektrixUk::Internal::Venue::ALL.each_value do |venue|
      assert_kind_of Float, venue.latitude
      assert_kind_of Float, venue.longitude
      assert_match(%r{\Ahttps://.+42\z}, format(venue.booking_url, instance: '42'))
    end
  end

  private

  def film?(venue_id, event)
    SpektrixUk::Internal::Venue.find(venue_id).film?({ 'name' => 'Wicker' }.merge(event))
  end
end
