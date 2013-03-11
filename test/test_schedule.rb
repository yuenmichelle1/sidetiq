require_relative 'helper'

class TestSchedule < Sidetiq::TestCase
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

