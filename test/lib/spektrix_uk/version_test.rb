require_relative '../../test_helper'

class SpektrixUk::VersionTest < Minitest::Test
  def test_version_is_defined
    refute_nil SpektrixUk::VERSION
  end
end
