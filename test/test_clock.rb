require_relative 'helper'

class TestClock < MiniTest::Unit::TestCase
  def test_gettime_seconds
    assert_equal Sidetiq::Clock.instance.gettime.tv_sec, Time.now.tv_sec
  end

  def test_gettime_nsec
    refute_nil Sidetiq::Clock.instance.gettime.tv_nsec
  end
end

