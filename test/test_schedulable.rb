require_relative 'helper'

class TestShedulable < Sidetiq::TestCase
  class FakeWorker
    include Sidetiq::Schedulable
  end

  def test_resheduling
    last_run = (Time.now - 100).to_f
    next_run = (Time.now + 100).to_f

    Sidekiq.redis do |redis|
      redis.set "sidetiq:TestShedulable::FakeWorker:last", last_run
      redis.set "sidetiq:TestShedulable::FakeWorker:next", next_run
    end

    assert FakeWorker.schedule_description == nil

    FakeWorker.schedule = nil
    FakeWorker.recurrence { minutely }

    assert FakeWorker.schedule_description == "Minutely"
    assert FakeWorker.last_scheduled_occurrence == -1.0
    assert FakeWorker.next_scheduled_occurrence == -1.0

    Sidekiq.redis do |redis|
      redis.set "sidetiq:TestShedulable::FakeWorker:last", last_run
      redis.set "sidetiq:TestShedulable::FakeWorker:next", next_run
    end

    FakeWorker.schedule = nil
    FakeWorker.recurrence { minutely }

    assert FakeWorker.schedule_description == "Minutely"
    assert FakeWorker.last_scheduled_occurrence == last_run
    assert FakeWorker.next_scheduled_occurrence == next_run

    FakeWorker.schedule = nil
    FakeWorker.recurrence { hourly }

    assert FakeWorker.schedule_description == "Hourly"
    assert FakeWorker.last_scheduled_occurrence == -1.0
    assert FakeWorker.next_scheduled_occurrence == -1.0
  end
end
