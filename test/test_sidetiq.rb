require_relative 'helper'

class TestSidetiq < Sidetiq::TestCase
  def test_schedules
    assert_equal Sidetiq.schedules, Sidetiq::Clock.schedules
    assert_equal [ScheduledWorker], Sidetiq.schedules.keys
    assert_kind_of Sidetiq::Schedule, Sidetiq.schedules[ScheduledWorker]
  end
end

