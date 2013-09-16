module Sidetiq
  # Public: The Sidetiq clock.
  class Clock
    include Logging

    # Internal: Returns a hash of Sidetiq::Schedule instances.
    attr_reader :schedules

    def initialize # :nodoc:
      super
      @schedules = {}
    end

    # Public: Get the schedule for `worker`.
    #
    # worker - A Sidekiq::Worker class
    #
    # Examples
    #
    #   schedule_for(MyWorker)
    #   # => Sidetiq::Schedule
    #
    # Returns a Sidetiq::Schedule instances.
    def schedule_for(worker)
      schedules[worker] ||= Sidetiq::Schedule.new
    end

    # Public: Issue a single clock tick.
    #
    # Examples
    #
    #   tick
    #   # => Hash of Sidetiq::Schedule objects
    #
    # Returns a hash of Sidetiq::Schedule instances.
    def tick
      tick = gettime
      schedules.each do |worker, sched|
        Lock.new(worker).synchronize do |redis|
          if sched.backfill? && (last = worker.last_scheduled_occurrence) > 0
            last = Sidetiq.config.utc ? Time.at(last).utc : Time.at(last)
            sched.occurrences_between(last + 1, tick).each do |past_t|
              enqueue(worker, past_t, redis)
            end
          end
          enqueue(worker, sched.next_occurrence(tick), redis)
        end if sched.schedule_next?(tick)
      end
    end

    # Public: Returns the current time used by the clock.
    #
    # Examples
    #
    #   gettime
    #   # => 2013-02-04 12:00:45 +0000
    #
    # Returns a Time instance.
    def gettime
      Sidetiq.config.utc ? Time.now.utc : Time.now
    end

    private

    def enqueue(worker, time, redis)
      key      = "sidetiq:#{worker.name}"
      time_f   = time.to_f
      next_run = (redis.get("#{key}:next") || -1).to_f

      if next_run < time_f
        info "Enqueue: #{worker.name} (at: #{time_f}) (last: #{next_run})"

        redis.mset("#{key}:last", next_run, "#{key}:next", time_f)

        case worker.instance_method(:perform).arity.abs
        when 0
          worker.perform_at(time)
        when 1
          worker.perform_at(time, next_run)
        else
          worker.perform_at(time, next_run, time_f)
        end
      end
    end
  end
end

