require_relative '../../test_helper'

class SpektrixUk::CinemaTest < Minitest::Test
  def test_new_stores_string_id
    assert_equal 'tyneside', SpektrixUk::Cinema.new(:tyneside).id
  end

  def test_all_returns_every_venue
    cinemas = SpektrixUk::Cinema.all

    assert(cinemas.all? { |cinema| cinema.instance_of?(SpektrixUk::Cinema) })
    assert_equal %w(broadway home hpph showroom tyneside), cinemas.map(&:id)
  end

  def test_name_and_full_name
    assert_equal 'Tyneside Cinema', cinema.name
    assert_equal 'Independent Tyneside Cinema', cinema.full_name
  end

  def test_brand
    assert_equal 'Independent', cinema.brand
  end

  def test_slug
    assert_equal 'independent-hyde-park-picture-house', SpektrixUk::Cinema.new('hpph').slug
  end

  def test_url
    assert_equal 'https://tynesidecinema.co.uk', cinema.url
  end

  def test_coordinates
    assert_in_delta 54.9739, cinema.latitude, 0.001
    assert_in_delta(-1.6123, cinema.longitude, 0.001)
  end

  def test_adr
    expected = {
      street_address:   '10 Pilgrim Street',
      extended_address: nil,
      locality:         'Newcastle upon Tyne',
      region:           nil,
      postal_code:      'NE1 6QG',
      country_name:     'United Kingdom'
    }

    assert_equal expected, cinema.adr
    assert_equal 'NE1 6QG', cinema.postal_code
    assert_equal 'Newcastle upon Tyne', cinema.locality
  end

  def test_unknown_cinema
    assert_raises(KeyError) { SpektrixUk::Cinema.new('nowhere').name }
  end

  private

  def cinema
    SpektrixUk::Cinema.new('tyneside')
  end
end
