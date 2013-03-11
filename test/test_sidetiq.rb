require_relative 'helper'

class TestSidetiq < Sidetiq::TestCase
  def teardown
    Sidekiq::ScheduledSet.new.map(&:delete)
  end

  def test_schedules
    assert_equal Sidetiq.schedules, Sidetiq::Clock.schedules
    assert_equal [ScheduledWorker], Sidetiq.schedules.keys
    assert_kind_of Sidetiq::Schedule, Sidetiq.schedules[ScheduledWorker]
  end

  def test_workers
    assert_equal [ScheduledWorker], Sidetiq.workers
  end

  def test_scheduled
    SimpleWorker.perform_at(Time.local(2011, 1, 1, 1))
    SimpleWorker.client_push_old(SimpleWorker.jobs.first)

    scheduled = Sidetiq.scheduled

    assert_kind_of Array, scheduled
    assert_kind_of Sidekiq::SortedEntry, scheduled.first
    assert_equal 1, scheduled.length
  end

  def test_scheduled_given_arguments
    SimpleWorker.perform_at(Time.local(2011, 1, 1, 1))
    SimpleWorker.client_push_old(SimpleWorker.jobs.first)

    assert_equal 1, Sidetiq.scheduled(SimpleWorker).length
    assert_equal 0, Sidetiq.scheduled(ScheduledWorker).length

    assert_equal 1, Sidetiq.scheduled("SimpleWorker").length
    assert_equal 0, Sidetiq.scheduled("ScheduledWorker").length
  end

  def test_scheduled_yields_each_job
    SimpleWorker.perform_at(Time.local(2011, 1, 1, 1))
    SimpleWorker.client_push_old(SimpleWorker.jobs.first)

    ScheduledWorker.perform_at(Time.local(2011, 1, 1, 1))
    ScheduledWorker.client_push_old(ScheduledWorker.jobs.first)

    jobs = []
    Sidetiq.scheduled { |job| jobs << job }
    assert_equal 2, jobs.length

    jobs = []
    Sidetiq.scheduled(SimpleWorker) { |job| jobs << job }
    assert_equal 1, jobs.length

    jobs = []
    Sidetiq.scheduled("ScheduledWorker") { |job| jobs << job }
    assert_equal 1, jobs.length
  end

  def test_scheduled_with_invalid_class
    assert_raises(NameError) do
      Sidetiq.scheduled("Foobar")
    end
  end
end

