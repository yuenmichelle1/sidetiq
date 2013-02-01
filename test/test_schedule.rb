require_relative 'helper'

class TestSchedule < MiniTest::Unit::TestCase
  def test_super
    assert_equal IceCube::Schedule, Sidetiq::Schedule.superclass
  end

  def test_method_missing
    sched = Sidetiq::Schedule.new
    sched.daily
    assert_equal "Daily", sched.to_s
  end

  def test_schedule_next?
    sched = Sidetiq::Schedule.new

    sched.daily

    assert sched.schedule_next?(Time.now + (24 * 60 * 60))
    refute sched.schedule_next?(Time.now + (24 * 60 * 60))
    assert sched.schedule_next?(Time.now + (2 * 24 * 60 * 60))
    refute sched.schedule_next?(Time.now + (2 * 24 * 60 * 60))
  end
end

