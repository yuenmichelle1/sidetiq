require_relative 'helper'

class TestErrors < Sidetiq::TestCase
  def test_error_superclass
    assert_equal StandardError, Sidetiq::Error.superclass
  end
end
