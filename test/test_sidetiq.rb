require_relative 'helper'

class TestSidetiq < MiniTest::Unit::TestCase
  class Worker
    include Sidekiq::Worker
    include Sidetiq::Schedulable

    tiq do
      daily.hour_of_day(0)
    end
  end

  def clock
    @clock ||= Sidetiq::Clock.instance
  end

  def tick
    clock.tick
  end

  def test_scheduling
    assert_equal 0, Worker.jobs.size # sanity

    clock.stubs(:gettime).returns(Time.now + (24 * 60 * 60))
    tick
    assert_equal 1, Worker.jobs.size

    clock.stubs(:gettime).returns(Time.now + (2 * 24 * 60 * 60))
    tick
    assert_equal 2, Worker.jobs.size

    clock.stubs(:gettime).returns(Time.now + (2 * 24 * 60 * 60 + 1))
    tick
    assert_equal 2, Worker.jobs.size
  end
end

