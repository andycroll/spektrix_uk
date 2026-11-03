require_relative '../../../test_helper'

class SpektrixUk::Internal::TitleSanitizerTest < Minitest::Test
  def test_removes_notes_and_certificates
    assert_sanitized 'Akira', 'Classics: Akira [35mm]'
    assert_sanitized 'Little Women', 'Little Women (2019) [2026]'
    assert_sanitized 'Wicker', 'Wicker (15) '
    assert_sanitized 'Metropolis Turns 100', 'Metropolis Turns 100 (PG) [With Live Score]'
  end

  def test_removes_strands
    assert_sanitized 'The Muppet Christmas Carol', 'Christmas 26 - FT: The Muppet Christmas Carol'
    assert_sanitized 'Klara and the Sun', 'Baby & Carer/ Klara and the Sun (12A)'
    assert_sanitized 'Violette', 'FFF26 x Presents: Violette'
    assert_sanitized 'Strange Days', 'FFS26 Strange Days'
    assert_sanitized 'Animal Farm', 'Family Film Club - Animal Farm'
    assert_sanitized 'Dune: Part Three', 'See It First – Dune: Part Three'
    assert_sanitized 'Whispers in the Woods', 'FFF26: Whispers in the Woods (Preview)'
  end

  def test_removes_extras_and_versions
    assert_sanitized 'Elf', 'Festive Afternoon Tea + Elf [2026]'
    assert_sanitized 'The Holiday', 'The Holiday + Popcorn & Prosecco [2026]'
    assert_sanitized 'Tampopo', 'Tampopo + Introduction'
    assert_sanitized 'Elf', 'Elf - Pay What You Feel'
    assert_sanitized 'The Polar Express', 'The Polar Express Family Event [2026]'
    assert_sanitized 'Pan\'s Labyrinth', 'Pan\'s Labyrinth: 20th Anniversary - Presented by Behind the Screen'
    assert_sanitized 'Pan\'s Labyrinth', 'Pan\'s Labyrinth (20th Anniversary 4K Restoration)'
    assert_sanitized 'Coward', 'Coward (French Film Festival)'
  end

  def test_removes_q_and_a
    assert_sanitized 'Lost Christmas', 'Lost Christmas + Q&A with Suzy Eddie Izzard'
    assert_sanitized 'We, The Hated', 'DocNights: We, The Hated [+ Filmmaker Q&A]'
    assert_sanitized 'Polite Society', 'Polite Society (12A) + Q&A'
  end

  def test_standardises_event_cinema
    assert_sanitized 'National Theatre Live: Hay Fever', 'NT Live: Hay Fever'
    assert_sanitized 'National Theatre Live: Golden Boy', 'NTL: Golden Boy'
    assert_sanitized 'National Theatre Live: Golden Boy', 'NT Live/ Golden Boy (12A)'
    assert_sanitized 'Royal Ballet and Opera: The Nutcracker', 'Christmas 26 - RBO: The Nutcracker'
    assert_sanitized 'Royal Ballet and Opera: The Nutcracker', 'Royal Ballet/ The Nutcracker (CTBA)'
    assert_sanitized 'Royal Ballet and Opera: Tosca', 'The Royal Opera: Tosca'
    assert_sanitized 'Met Opera: Parsifal', 'Parsifal - Met Opera 26/27'
    assert_sanitized 'Exhibition on Screen: Monet', 'EOS: Monet [2027]'
  end

  def test_keeps_titles_with_their_own_subtitles
    [
      'Ghosts: The Possession of Button House',
      'Dune: Part 3',
      'Doctor Who: The Satan Pit',
      'Spotlight'
    ].each { |title| assert_sanitized title, title }
  end

  def test_live_on_stage
    assert_sanitized "Andrew Lloyd Webber's Starlight Express", "Andrew Lloyd Webber's Starlight Express - Live On Stage"
  end

  private

  def assert_sanitized(expected, title)
    assert_equal expected, SpektrixUk::Internal::TitleSanitizer.new(title.strip).sanitized
  end
end
