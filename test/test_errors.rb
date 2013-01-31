require_relative 'helper'

class TestErrors < MiniTest::Unit::TestCase
  def test_error_superclass
    assert_equal StandardError, Sidetiq::Error.superclass
  end
end
